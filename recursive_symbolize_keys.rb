#!/usr/bin/env ruby
require 'json'
require 'multi_json'

def rsk! coll
  if coll.respond_to? :each and !coll.is_a?( String )
    coll.symbolize_keys! if coll.is_a?( Hash )
    coll.each do |el|
      if el.respond_to? :each and !coll.is_a?( String )
        rsk! el
      end
    end 
  end 
  coll
end

