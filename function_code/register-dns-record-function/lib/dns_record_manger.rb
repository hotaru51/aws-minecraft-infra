# frozen_string_literal: true

require 'logger'
require 'aws-sdk'

class DnsRecordManager
  def initialize
    @client = Aws::Route53::Client.new
    @logger = Logger.new(STDOUT)
    @zone_id = ENV['PUBLIC_HOSTED_ZONE_ID']
    @zone_name = ENV['PUBLIC_HOSTED_ZONE_NAME']
  end

# レコードの存在確認
  def exists_dns_record?(record_name)
    # ホストゾーンのレコード一覧取得
    @logger.info("get record list: zone_id = #{@zone_id}")
    records = @client.list_resource_record_sets({ hosted_zone_id: @zone_id })

    # 対象のレコードのオブジェクトを取得
    target_record_name = "#{record_name}.#{@zone_name}."
    filtered = records['resource_record_sets'].filter do |item|
      item['name'] == target_record_name && item['type'] == 'A'
    end
    @logger.info("filtered record length: #{filtered.length}")

    filtered.length >= 1
  end
end
