module Cache
  class Repository
    delegate 'config', to: Cache
    delegate 'dump', to: Marshal

    attr_reader :repo, :prefix, :key, :ttl

    def initialize(prefix, params = {})
      @prefix = params.key?(:prefix) ? params[:prefix] : prefix
      @key    = params.key?(:key)    ? params[:key]    : config.key
      @ttl    = params.key?(:ttl)    ? params[:ttl]    : config.ttl
      set_repo(params[:schema])
    end

    def get(value)
      repo.get(generate_key(value))
    end

    def set(object)
      !!repo.setex(generate_key(object.send(key)), ttl, object.serialized_to_cache)
    end

    def exists?(value)
      repo.exists(generate_key(value))
    end

    private

    def set_repo(params)
      param = config.schema
      param.merge(params) unless params.blank? || params.empty?
      @repo = Redis.new(param) 
    end

    def config
      Cache.config
    end

    def generate_key(value)
      "#{prefix}-#{value}"
    end

  end
end