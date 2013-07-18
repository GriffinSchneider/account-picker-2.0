require "rubygems"
require "sinatra"
require "data_mapper"
require "json"

DataMapper.setup(:default, ENV['DATABASE_URL'] || "sqlite://#{File.expand_path(File.dirname(__FILE__))}/accounts.db")
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
    # Check if this account has already been added.
    account = Account.first(:stage.like => stage,
                            :email.like => email)

    if not account then
        account = Account.create(:country_code => country_code,
                                 :stage => stage,
                                 :email => email,
                                 :device_id => "none")
        print "\nAdded account: #{account.to_json}\n"
    end

    account
end

# Get an account
get GET_ACCOUNT do
    get_account(params[:country_code], params[:stage], params[:device_id]).to_json
end

def get_account(country_code, stage, device_id)
    # Try to find an account already reserved for this device id
    account = Account.first(:country_code.like => country_code,
                            :stage.like => stage,
                            :device_id => device_id)

    # If there wasn't one, try to find an unreserved account and reserve it
    account ||= Account.first(:country_code.like => country_code,
                              :stage.like => stage,
                              :device_id => "none")
    
    if account and account.device_id == "none" and device_id then
        account.update(:device_id => device_id)
    end
    
    account
end

# Remove all accounts for a stage
get CLEAR_ACCOUNTS do
    print "\nClearing accounts for stage:#{params[:stage]}"
    if params[:stage] == "all" then
        Account.all.destroy
    else
        Account.all(:stage.like => stage).destroy
    end
end
