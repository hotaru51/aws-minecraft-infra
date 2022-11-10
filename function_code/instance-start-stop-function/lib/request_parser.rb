# frozen_string_literal: true
require 'logger'
require 'uri'

class RequestParser
  attr_accessor :path, :query_string

  def initialize(event)
    @logger = Logger.new(STDOUT)

    @path = event['rawPath']
    @raw_query_string = event['rawQueryString']
    @query_string = parse_query_string
  end

  # 有効なpathか確認する
  def valid_path?
    @path == '/stop' || @path == '/start'
  end

  private

  # raw_query_stringをhashに変換する
  def parse_query_string
    query_arr = URI.decode_www_form(@raw_query_string)
    Hash[query_arr]
  end
end
