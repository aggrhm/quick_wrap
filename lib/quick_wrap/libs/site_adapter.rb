module QuickWrap

  class SiteAdapter

    def self.register(key, host=nil, &block)
      a = SiteAdapter.new(host)
      self.adapters[key] = a
      block.call(a) unless block.nil?
      return a
    end

    def self.[](key)
      @adapters[key]
    end

    def self.adapters
      @adapters ||= {}
    end

    def initialize(host, opts={})
      self.host = host
      @options = opts
      @options[:response_class] = JSONResponse
      @state = :ready
      @requests = []
      @before_request_fn = nil
    end

    def host=(host)
      return if host.nil?
      if host.match(/^http[s]?:\/\/.*/)
        @host = host
      else
        @host = "http://#{host}"
      end
    end

    def host
      @host ||= 'http://localhost:3000/api'
    end

    def headers
      @headers ||= {}
    end

    def options
      @options ||= {}
    end

    def before_request(&block)
      @before_request_fn = block
    end

    def history
      @history ||= []
    end

    def connect(path, data, method=:POST, opts={}, &callback)
      r = {}
      r[:path] = path
      r[:data] = data
      r[:method] = method
      r[:opts] = opts
      r[:callback] = callback

      if !@before_request_fn.nil?
        @before_request_fn.call(r)
      end

      if @state == :ready
        execute_request(r)
      else
        @requests << r
      end
      return nil
    end

    def pause_requests
      @state = :paused
    end

    def resume_requests
      @state = :ready
      process_requests
    end

    def process_requests
      @requests.each do |req|
        execute_request(req)
      end
      @requests.clear
    end

    def execute_request(request)
      path = request[:path]
      method = request[:method]
      data = request[:data]
      opts = request[:opts]
      callback = request[:callback]

      full_path = "#{self.host}#{path}"
      opts[:payload] = self.process_params(data)
      opts[:headers] = @headers
      # log request
      QuickWrap.log "#{method.to_s} #{path}"
      resp_class = opts[:response_class] || self.options[:response_class]

      BW::HTTP.send(method.to_s.downcase, full_path, opts) do |response|
        resp_body = response.body.nil? ? nil : response.body.to_str
        QuickWrap.log "#{response.status_code} - #{resp_body}"
        resp = resp_class.new(resp_body, response.status_code)
        callback.call(resp) unless callback.nil?

        self.history << {method: method, path: full_path, data: data, resp: resp, size: response.body ? response.body.to_str.length : 0} if self.options[:keep_history]
      end
      return nil
    end

    def process_params(params)
      return nil if params.nil?
      ret = params.select{|k, v| !v.nil?}
    end

    class JSONResponse
      def initialize(body, status)
        @body = body
        @status = status
        begin
          @resp = BW::JSON.parse(@body)
        rescue
          @resp = nil
        end
      end

      def [](field)
        @resp[field]
      end

      def ok?
        @status == 200
      end
    end

    class APIResponse
      def initialize(body, status)
        @body = body
        @status = status
        set_error if body.nil?
        begin
          @resp = BW::JSON.parse(@body)
        rescue
          set_error
        end
      end
      def [](field)
        @resp[field]
      end
      def data
        @resp['data']
      end
      def meta
        @resp['meta']
      end
      def ok?
        @status == 200 && @resp['meta'] == 200
      end
      def error_msg
        @resp['error'] || @resp['data']['errors'][0]
      end
      def set_error(err="An error occurred at the server.", meta=500)
        @resp = {'success' => false, 'error' => err, 'meta' => meta}
      end
    end

  end

  class AuthToken

    def initialize(data)
      @data = data
      @expires_at = Time.now.to_i + data[:expires_in]
      #@expires_at = Time.now.to_i + 10
    end

    def [](field)
      @data[field]
    end

    def data
      @data
    end

    def access_token
      @data[:access_token]
    end

    def refresh_token
      @data[:refresh_token]
    end

    def expired?
      Time.now.to_i > @expires_at
    end

  end

end
