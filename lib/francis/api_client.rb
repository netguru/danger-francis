require "typhoeus"
require "json"

class ApiClient

  def self.get(url, authorization = nil)
    request = Typhoeus::Request.new(
      url,
      method: :get,
      headers: { "Authorization": authorization }
    )
    resp = request.run
    unless resp.success?
      warn("Send failed with code: #{resp.code} body: #{resp.body}")
    end
    JSON.parse(resp.body)
  end

end
