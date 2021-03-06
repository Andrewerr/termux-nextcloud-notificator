require 'httparty'
require 'json'
require 'termux.rb'
require 'logging.rb'

module Auth
  def self.authenticate(endpoint, poll_time=2)
      Logging::info("Authenticating at #{endpoint}")
      resp=HTTParty.post("https://#{endpoint}/index.php/login/v2")
      json=JSON.parse(resp.body)
      poll=json["poll"]["endpoint"]
      token=json["poll"]["token"]
      login=json["login"]
      Logging::info("Opening login page #{login}")
      Termux::open_url(login)
      Logging::debug("token=#{token}")
      authorised=false
      while not authorised
          resp=HTTParty.post("https://cloud.p01ar.net/index.php/login/v2/poll", :body=> {:token => token})
          Logging::debug("Polling response code #{resp.code}")
          if resp.code == 200 then
             authorised=true
          end
          sleep(poll_time)
     end
     Logging::info("Authentication succeeded")
     token=JSON.parse(resp.body)["appPassword"]
     token
  end
end
