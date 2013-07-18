Account Picker 2.0
------------------


It's an account picker. It reserves each account for the first device id that gets it.

- GET /addAccount/:country_code/:stage/:email to add an account.
- GET /getAccount/:country_code/:stage/:device_id to get an account as a JSON object.
- GET /clearAccounts/:stage to remove all accounts for a given stage.
