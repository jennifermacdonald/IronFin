# frozen_string_literal: true

module V1
  module Actor
    class IndexSerializer

      def self.format_json(actors)
        actors.map do |actor|
          {
              firstName: actor['first'],
              lastName: actor['last'],
              gender: actor['sex'],
              dateOfBirth: Date.parse(actor['dob'], '%Y/%m/%d'),
              dateOfDeath: actor['dod']
          }
        end
      end
    end
  end
end