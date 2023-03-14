const setCompany = () => {
  cy.intercept(
    'POST',
    'http://localhost:3000/companies/find_or_create',
    {
      statusCode: 200,
      body: {
        status: 200,
        id: 1
      }
    }
  )

  cy.get('[data-cy=company-name]').type('Cool Company')
  cy.get('[data-cy=company-siren]').type('1234')
  cy.get('[data-cy=submit-company]').click()
}

const setCustomer = () => {
  cy.intercept(
    'POST',
    'http://localhost:3000/customers/find_or_create',
    {
      statusCode: 200,
      body: {
        status: 200,
        id: 1
      }
    }
  )

  cy.get('[data-cy=customer-name]').type('Cool Customer')
  cy.get('[data-cy=customer-email]').type('cool-customer@email.com')
  cy.get('[data-cy=customer-phone]').type('0610101010')
  cy.get('[data-cy=submit-customer]').click()
}

const setInstallation = () => {
  cy.intercept(
    'POST',
    'http://localhost:3000/installations',
    {
      statusCode: 200,
      body: {
        status: 200,
        id: 1
      }
    }
  )

  cy.get('[data-cy=installation-date]').type('2023-03-14')
  cy.get('[data-cy=installation-address]').type('10 Rue de là bas')
  cy.get('[data-cy=installation-city]').type('Cool City')
  cy.get('[data-cy=submit-installation]').click()
}

describe('App', () => {
  beforeEach(() => {
    cy.visit('/')
  })

  it('displays the header', () => {
    cy.get('[data-cy=header] img').should('have.attr', 'src', '/src/assets/logo.png')
  })

  it('displays the footer', () => {
    cy.get('[data-cy=footer] p').should('have.text', 'DualSun, +33 4 13 41 53 70, contact@dualsun.fr')
  })

  context('when API is available', () => {
    context('company step', () => {
      it('does not display form summaries', () => {
        cy.get('[data-cy=company-summary]').should('not.exist')
        cy.get('[data-cy=customer-summary]').should('not.exist')
        cy.get('[data-cy=installation-summary]').should('not.exist')
        cy.get('[data-cy=panels-summary]').should('not.exist')
      })

      it('displays company form', () => {
        cy.get('[data-cy=company-form] h2').should('have.text', 'Company Infos')
        cy.get('[data-cy=company-name]').should('have.attr', 'placeholder', 'Name')
        cy.get('[data-cy=company-siren]').should('have.attr', 'placeholder', 'Siren')
        cy.get('[data-cy=company-name]').should('have.attr', 'placeholder', 'Name')
        cy.get('[data-cy=submit-company]')
          .should('have.class', 'button', 'primary')
          .and('have.text', 'Continue')
      })

      it('does not display other forms', () => {
        cy.get('[data-cy=customer-form]').should('not.exist')
        cy.get('[data-cy=installation-form]').should('not.exist')
        cy.get('[data-cy=panels-form]').should('not.exist')
      })

      context('when company is valid', () => {
        it('receives company data and goes to customer step', () => {
          cy.intercept(
            'POST',
            'http://localhost:3000/companies/find_or_create',
            {
              statusCode: 200,
              body: {
                status: 200,
                id: 1
              }
            }
          ).as('findOrCreateCompany')

          cy.get('[data-cy=company-name]').type('Cool Company')
          cy.get('[data-cy=company-siren]').type('1234')
          cy.get('[data-cy=submit-company]').click()

          cy.wait('@findOrCreateCompany').its('request.body').then(({ name, siren }) => {
            expect(name).to.eq('Cool Company')
            expect(siren).to.eq('123456')
          })

          cy.get('[data-cy=customer-form]').should('be.visible')
        })
      })

      context('when company is not valid', () => {
        it('displays company errors', () => {
          cy.intercept(
            'POST',
            'http://localhost:3000/companies/find_or_create',
            {
              statusCode: 422,
              body: {
                status: 422,
                errors: {
                  name: ['can\'t be blank'],
                  siren: ['is not a number']
                }
              }
            }
          )

          cy.get('[data-cy=company-siren]').type('ABCDE')
          cy.get('[data-cy=submit-company]').click()

          cy.get('[data-cy=input-error-name]').should('contain', 'can\'t be blank')
          cy.get('[data-cy=input-error-siren]').should('contain', 'is not a number')
        })
      })
    })

    context('customer step', () => {
      beforeEach(() => {
        setCompany()
      })

      it('displays company summary', () => {
        cy.get('[data-cy=company-summary]').should('be.visible')
        cy.get('[data-cy=customer-summary]').should('not.exist')
        cy.get('[data-cy=installation-summary]').should('not.exist')
        cy.get('[data-cy=panels-summary]').should('not.exist')
      })

      it('displays customer form', () => {
        cy.get('[data-cy=customer-form] h2').should('have.text', 'Customer Infos')
        cy.get('[data-cy=customer-name]').should('have.attr', 'placeholder', 'Name')
        cy.get('[data-cy=customer-email]').should('have.attr', 'placeholder', 'Email')
        cy.get('[data-cy=customer-phone]').should('have.attr', 'placeholder', 'Phone')
        cy.get('[data-cy=submit-customer]')
          .should('have.class', 'button', 'primary')
          .and('have.text', 'Continue')
      })

      it('does not display other forms', () => {
        cy.get('[data-cy=company-form]').should('not.exist')
        cy.get('[data-cy=installation-form]').should('not.exist')
        cy.get('[data-cy=panels-form]').should('not.exist')
      })

      context('When customer is valid', () => {
        it('receives customer data and goes to installation step', () => {
          cy.intercept(
            'POST',
            'http://localhost:3000/customers/find_or_create',
            {
              statusCode: 200,
              body: {
                status: 200,
                id: 1
              }
            }
          ).as('findOrCreateCustomer')

          cy.get('[data-cy=customer-name]').type('Cool Customer')
          cy.get('[data-cy=customer-email]').type('cool-customer@email.com')
          cy.get('[data-cy=customer-phone]').type('0610101010')
          cy.get('[data-cy=submit-customer]').click()

          cy.wait('@findOrCreateCustomer').its('request.body').then(({ name, email, phone }) => {
            expect(name).to.eq('Cool Customer')
            expect(email).to.eq('cool-customer@email.com')
            expect(phone).to.eq('0610101010')
          })

          cy.get('[data-cy=installation-form] h2').should('be.visible')
        })
      })

      context('when customer is not valid', () => {
        it('displays customer errors', () => {
          cy.intercept(
            'POST',
            'http://localhost:3000/customers/find_or_create',
            {
              statusCode: 422,
              body: {
                status: 422,
                errors: {
                  name: ['can\'t be blank'],
                  email: ['is not valid'],
                  phone: ['can\'t be blank']
                }
              }
            }
          )

          cy.get('[data-cy=customer-email]').type('not-an-email')
          cy.get('[data-cy=submit-customer]').click()

          cy.get('[data-cy=input-error-name]').should('contain', 'can\'t be blank')
          cy.get('[data-cy=input-error-email]').should('contain', 'is not valid')
          cy.get('[data-cy=input-error-phone]').should('contain', 'can\'t be blank')
        })
      })
    })

    context('installation step', () => {
      beforeEach(() => {
        setCompany()
        setCustomer()
      })

      it('displays company and customer summaries', () => {
        cy.get('[data-cy=company-summary]').should('be.visible')
        cy.get('[data-cy=customer-summary]').should('be.visible')
        cy.get('[data-cy=installation-summary]').should('not.exist')
        cy.get('[data-cy=panels-summary]').should('not.exist')
      })

      it('displays installation form', () => {
        cy.get('[data-cy=installation-form] h2').should('have.text', 'Installation Details')
        cy.get('[data-cy=installation-date]').should('have.attr', 'type', 'date')
        cy.get('[data-cy=installation-address]').should('have.attr', 'placeholder', 'Address')
        cy.get('[data-cy=installation-city]').should('have.attr', 'placeholder', 'City')
        cy.get('[data-cy=submit-installation]')
          .should('have.class', 'button', 'primary')
          .and('have.text', 'Continue')
      })

      it('does not display other forms', () => {
        cy.get('[data-cy=company-form]').should('not.exist')
        cy.get('[data-cy=customer-form]').should('not.exist')
        cy.get('[data-cy=panels-form]').should('not.exist')
      })

      context('When installation is valid', () => {
        it('receives installation data and goes to panels step', () => {
          cy.intercept(
            'POST',
            'http://localhost:3000/installations',
            {
              statusCode: 200,
              body: {
                status: 200,
                id: 1
              }
            }
          ).as('createInstallation')

          cy.get('[data-cy=installation-date]').type('2023-03-14')
          cy.get('[data-cy=installation-address]').type('10 Rue de là bas')
          cy.get('[data-cy=installation-city]').type('Cool City')
          cy.get('[data-cy=submit-installation]').click()

          cy.wait('@createInstallation').its('request.body').then(({ date, address, city, company_id, customer_id }) => {
            expect(date).to.eq('2023-03-14')
            expect(address).to.eq('10 Rue de là bas')
            expect(city).to.eq('Cool City')
            expect(company_id).to.eq(1)
            expect(customer_id).to.eq(1)
          })

          cy.get('[data-cy=panels-form] h2').should('be.visible')
        })
      })

      context('when installation is not valid', () => {
        it('displays installation errors', () => {
          cy.intercept(
            'POST',
            'http://localhost:3000/installations',
            {
              statusCode: 422,
              body: {
                status: 422,
                errors: {
                  date: ['can\'t be blank'],
                  address: ['can\'t be blank'],
                  city: ['can\'t be blank']
                }
              }
            }
          )

          cy.get('[data-cy=submit-installation]').click()

          cy.get('[data-cy=input-error-date]').should('contain', 'can\'t be blank')
          cy.get('[data-cy=input-error-address]').should('contain', 'can\'t be blank')
          cy.get('[data-cy=input-error-city]').should('contain', 'can\'t be blank')
        })
      })
    })

    context('panels step', () => {
      beforeEach(() => {
        setCompany()
        setCustomer()
        setInstallation()
      })

      it('displays company, customer and installation summaries', () => {
        cy.get('[data-cy=company-summary]').should('be.visible')
        cy.get('[data-cy=customer-summary]').should('be.visible')
        cy.get('[data-cy=installation-summary]').should('be.visible')
        cy.get('[data-cy=panels-summary]').should('not.exist')
      })

      it('displays panels form', () => {
        cy.get('[data-cy=panels-form] h2').should('have.text', 'Panels')
        cy.get('[data-cy=panel-code]').should('have.attr', 'placeholder', 'Code')
        cy.get('[data-cy=panel-flavor]').select('photovoltaic').should('have.value', 'photovoltaic')
        cy.get('[data-cy=panel-flavor]').select('hybrid').should('have.value', 'hybrid')
        cy.get('[data-cy=submit-panels]')
          .should('have.class', 'button', 'primary')
          .and('have.text', 'Confirm Installation')
      })

      it('does not display other forms', () => {
        cy.get('[data-cy=company-form]').should('not.exist')
        cy.get('[data-cy=customer-form]').should('not.exist')
        cy.get('[data-cy=installation-form]').should('not.exist')
      })

      it('allows to add and remove panels', () => {
        cy.get('[data-cy=panel-form]').should('have.length', 1)
        cy.get('[data-cy=add-panel]').click().click()
        cy.get('[data-cy=panel-form]').should('have.length', 3)

        cy.get('[data-cy=panel-code]').first().type('123456')

        cy.get('[data-cy=remove-panel]').last().click()
        cy.get('[data-cy=remove-panel]').last().click()

        cy.get('[data-cy=panel-code]').should('have.value', '123456')
      })

      context('When panels are valid', () => {
        it('receives panels data and confirm form has been sent', () => {
          cy.intercept(
            'POST',
            'http://localhost:3000/panels/bulk_create',
            {
              statusCode: 200,
              body: {
                status: 200
              }
            }
          ).as('bulkCreatePanels')

          cy.get('[data-cy=panel-code]').type('123456')
          cy.get('[data-cy=panel-flavor]').select('photovoltaic')
          cy.get('[data-cy=add-panel]').click()
          cy.get('[data-cy=panel-code]').last().type('000000')
          cy.get('[data-cy=panel-flavor]').last().select('hybrid')
          cy.get('[data-cy=submit-panels]').click()

          cy.wait('@bulkCreatePanels').its('request.body').then(({ panels, installation_id }) => {
            expect(panels[0].code).to.eq('123456')
            expect(panels[0].flavor).to.eq('photovoltaic')
            expect(panels[1].code).to.eq('000000')
            expect(panels[1].flavor).to.eq('hybrid')
            expect(installation_id).to.eq(1)
          })

          cy.get('[data-cy=panels-summary]').should('be.visible')

          cy.get('[data-cy=flash]')
            .should('be.visible')
            .and('have.class', 'success')
            .and('have.text', 'Your installation informations has been sent to DualSun. Thank you!')
        })
      })

      context('when some panels are missing a code', () => {
        it('prevents panels form submission and displays an error message', () => {
          cy.get('[data-cy=submit-panels]').click()
          cy.get('[data-cy=panels-global-error]').should('have.text', 'Please add Code to all panels before confirming your Installation.')
        })
      })

      context('when no panels are sent', () => {
        it('prevents panels form submission and displays an error message', () => {
          cy.get('[data-cy=remove-panel]').click()
          cy.get('[data-cy=submit-panels]').click()
          cy.get('[data-cy=panels-global-error]').should('have.text', 'Please add at least one Panel to your Installation.')
        })
      })

      context('when panels are not valid', () => {
        it('displays panels errors', () => {
          cy.intercept(
            'POST',
            'http://localhost:3000/panels/bulk_create',
            {
              statusCode: 422,
              body: {
                status: 422,
                errors: {
                  abcdef: { code: ['is not a number'] }
                }
              }
            }
          )

          cy.get('[data-cy=panel-code]').type('abcdef')
          cy.get('[data-cy=submit-panels]').click()

          cy.get('[data-cy=input-error-code]').should('contain', 'is not a number')
        })
      })
    })
  })

  context('when API is not available', () => {
    it('displays an error message', () => {
      cy.intercept(
        'POST',
        'http://localhost:3000/companies/find_or_create',
        { forceNetworkError: true }
      )

      cy.get('[data-cy=submit-company]').click()
    })
  })
})
