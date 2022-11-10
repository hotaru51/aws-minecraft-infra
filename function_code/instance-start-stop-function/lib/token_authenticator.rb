# frozen_string_literal: true

require 'logger'
require 'aws-sdk'

class TokenAuthenticator
  def initialize
    @logger = Logger.new(STDOUT)

    @ssm_client = Aws::SSM::Client.new
  end

  # トークンを照合する
  def authentication(token)
    param_token = get_token_from_parameter
    token == param_token
  end

  private

  # Parameter storeからトークンの値を取得
  def get_token_from_parameter
    param_name = ENV['TOKEN_PARAMETER_NAME']
    res = @ssm_client.get_parameter({ name: param_name })
    res['parameter']['value']
  end
end
