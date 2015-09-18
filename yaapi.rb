###################################
# Yaapi (Yet another api)
# 
# This is a super class to be inherited by 
# the domain classes of this application.
# Responsible for api calls and 
# error handling.
##
module Yaapi
  class Base
    class << self
      def get_all id = nil
        begin        
          url_base = self.path[:url]
          path = self.path[:fetch_all]
          path.sub! ":id", id.to_s
          url = url_base + path
          response = HTTParty.get(url)
          if status? response
            if response.parsed_response.is_a? Array
              response_object = []
              response.parsed_response.each do |api_object|
                response_object.push self.new api_object
              end
              return response_object
            end
          else
            return set_errors response
          end
        rescue Exception => ex
          return set_rescue ex
        end
      end
      ##
      # get id
      # fetch method, parses url provided by child class in path hash
      # and performs appropriate fetch
      # method returns class instance set by fetch
      def get id
        begin
          url_base = self.path[:url]
          path = self.path[:fetch]
          path.sub! ":id", id.to_s
          url = url_base + path
          response = HTTParty.get(url)
          if status? response
            api_instance = self.new response.parsed_response
            return api_instance
          else
            return set_errors response
          end
        rescue Exception => ex
          return set_rescue ex
        end
      end
      
      def update_existing options
        begin
          url_base = self.path[:url]
          path = self.path[:put]
          path.sub! ":id", options[:id].to_s
          api_model = self.new
          res = api_model.class.to_s.underscore.to_sym
          url = url_base + path
          body = {res => options}
          response = HTTParty.put(url, :body => body)
          if status? response
            return self.get options[:id]
          else
            return set_errors response
          end
        rescue Exception => ex
          return set_rescue ex
        end
      end
      
      def create_new options
        begin
          url_base = self.path[:url]
          path = self.path[:create]
          api_model = self.new
          res = api_model.class.to_s.underscore.to_sym
          url = url_base + path
          body = {res => options}
          response = HTTParty.post(url, :body => body)
          if status? response
            resp = (response.parsed_response[res.to_s].nil?) ? response.parsed_response : response.parsed_response[res.to_s]
            api_instance = self.new resp
            return api_instance
          else
            return set_errors response
          end
        rescue Exception => ex
          return set_rescue ex
        end
      end
    
      def delete_existing id
        begin
          url_base = self.path[:url]
          path = self.path[:delete]
          path.sub! ":id", id.to_s
          url = url_base + path
          response = HTTParty.delete(url)
          if status? response
            return self.new
          else
            return set_errors response
          end
        rescue Exception => ex
          return set_rescue ex
        end
      end
      
      private
    
      ##
      # status?
      # returns false if response code not success
      def status? response
        return [200, 201, 202, 203, 204, 205].include?(response.code.to_i)
        true
      end
      
      def set_errors response
        errors = []
        parsed_response = nil
        if response.respond_to? :parsed_response
          parsed_response = response.parsed_response
        end
        if parsed_response.is_a?(Array)
          parsed_response.each do |resp|
            key = resp[0].to_s.to_sym
            val = resp[1]
            errors.push({key => val })
          end
        end
        errors.push({:status => response.header["status"]})
        api_error = self.new
        add_errors api_error, errors
        return api_error
      end
      
      def set_rescue ex
        errors = []
        errors << {:message => ex.message}
        errors << {:stacktrace => ex.backtrace }
        Rails.logger.error "Received error: #{ex.message}"
        print_stacktrace ex.backtrace
        api_error = self.new
        add_errors api_error, errors
        return api_error
      end
    
      def add_errors instance, errors
        class << instance
          attr_accessor :errors
        end
        instance.errors = errors
      end
      
      def print_stacktrace stacktrace
        stacktrace.each { |t| Rails.logger.error "     #{t}"}
      end
    end
    
    def to_h
      sj = self.to_json
      return JSON.parse(sj)
    end
    
  end
end