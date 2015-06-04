require 'request_store'

module SentientUser

  def self.included(base)
    base.class_eval {
      def self.current
        RequestStore.store[self.name.downcase.to_sym]
      end

      def self.current=(o)
        unless (o.is_a?(self) || o.nil?)
          raise(ArgumentError,
                "Expected an object of class '#{self}', got #{o.inspect}")
        end

        RequestStore.store[self.name.downcase.to_sym] = o
      end

      def make_current
        RequestStore.store[self.name.downcase.to_sym] = self
      end

      def current?
        !RequestStore.store[self.name.downcase.to_sym].nil? &&
          self.id == RequestStore.store[self.name.downcase.to_sym].id
      end

      def self.do_as(user, &block)
        old_user = self.current

        begin
          self.current = user
          response = block.call unless block.nil?
        ensure
          self.current = old_user
        end

        response
      end
    }
  end
end
