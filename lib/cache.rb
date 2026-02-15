class Cache
  Entry = Struct.new(:value, :expires_at)

  def initialize(ttl: 86_400)
    @store = {}
    @ttl = ttl
    @mutex = Mutex.new
  end

  def get(key)
    @mutex.synchronize do
      entry = @store[key]
      return nil unless entry

      if Time.now > entry.expires_at
        @store.delete(key)
        return nil
      end
      entry.value
    end
  end

  def set(key, value)
    @mutex.synchronize do
      @store[key] = Entry.new(value, Time.now + @ttl)
      value
    end
  end

  def fetch(key)
    @mutex.synchronize do
      entry = @store[key]
      if entry && Time.now <= entry.expires_at
        return entry.value
      end

      @store.delete(key) if entry
      value = yield
      @store[key] = Entry.new(value, Time.now + @ttl)
      value
    end
  end

  def clear
    @mutex.synchronize { @store.clear }
  end
end
