puts "SITEADAPTER LOADING"
module QuickWrap

  module SiteAdapter

    def self.host=(host)
      if host.match(/^http[s]?:\/\/.*/)
        @host = host
      else
        @host = "http://#{host}"
      end
    end

    def self.api_version=(ver)
      @api_version = ver
    end

    def self.api_version
      @api_version ||= 1
    end

    def self.host
      @host ||= 'http://localhost:3000/api'
    end

    def self.connect(path, data, method=:POST, opts={}, &callback)
      full_path = "#{self.host}#{path}"
      opts[:payload] = self.process_params(data)
      opts[:payload][:api_ver] = self.api_version if opts[:payload][:api_ver].nil?
      # log request
      QuickWrap.log "#{method.to_s} #{path} #{data.inspect}"

      BW::HTTP.send(method.to_s.downcase, full_path, opts) do |response|
        callback.call self.process_response(response)
      end
      return nil
    end

    def self.process_response(response)
      QuickWrap.log response.body.to_str unless response.body.nil?
      if response.ok? && !response.body.nil?
        resp = BW::JSON.parse(response.body.to_str)
      else
        resp = {'data' => {'errors' => ['An error occurred at the server.']}, 'meta' => 500}
      end
      return RespData.new(resp)
    end

    def self.process_params(params)
      return nil if params.nil?
      ret = params.select{|k, v| !v.nil?}
    end

    class RespData
      def initialize(response)
        @resp = response
      end
      def data
        @resp['data']
      end
      def meta
        @resp['meta']
      end
      def ok?
        @resp['meta'] == 200
      end
      def error_msg
        @resp['data']['errors'][0]
      end
    end

  end

end
