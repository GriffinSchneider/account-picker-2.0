require "rubygems"
require "sinatra"
require "data_mapper"
require "json"

DataMapper.setup(:default, ENV['DATABASE_URL'] || 'postgres://localhost/mydb')
class Account
    include DataMapper::Resource

    property :id,    Serial
    property :country_code, String
    property :stage, String
    property :email, String
    property :device_id, String
end

DataMapper.finalize
DataMapper.auto_upgrade!

# Routes
ADD_ACCOUNT = "/addAccount/:country_code/:stage/:email"
GET_ACCOUNT = "/getAccount/:country_code/:stage/:device_id"
CLEAR_ACCOUNTS = "/clearAccounts/:stage"

# Documentation!
get "/" do
    "#{ADD_ACCOUNT}<br>#{GET_ACCOUNT}<br>#{CLEAR_ACCOUNTS}"
end

# Add an account
get ADD_ACCOUNT do
    add_account(params[:country_code], params[:stage], params[:email]).to_json
end

def add_account(country_code, stage, email)
    Account.first_or_create(:country_code => country_code,
                            :stage => stage,
                            :email => email,
                            :device_id => "none")
end

# Get an account
get GET_ACCOUNT do
    get_account(params[:country_code], params[:stage], params[:device_id]).to_json
end

def get_account(country_code, stage, device_id)
    account = Account.first(:country_code => country_code,
                            :stage => stage,
                            :device_id => device_id)
    return account if account
    
    new_account = Account.first(:country_code => country_code,
                                :stage => stage,
                                :device_id => "none")
    if new_account then
        new_account.update(:device_id => device_id)
        return new_account
    end
end

# Remove all accounts for a stage
get CLEAR_ACCOUNTS do
    if params[:stage].equals "all" then
        Account.all.destroy
    else
        Account.all(:stage => stage).destroy
    end
end
