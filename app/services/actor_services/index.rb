# frozen_string_literal: true

module ActorServices
  class Index
    attr_accessor :first_name , :last_name, :sex, :date_of_birth, :date_of_death, :movies_acted_in, :show_movies

    def initialize(first_name: nil, last_name: nil, sex: nil, date_of_birth: nil, date_of_death: nil, movies_acted_in: nil, show_movies: false)
      self.first_name = first_name
      self.last_name = last_name
      self.sex = sex
      self.date_of_birth = date_of_birth
      self.date_of_death = date_of_death
      self.movies_acted_in = movies_acted_in
      self.show_movies = show_movies

    end

    def run

      # get initial actors data in PG object
      actors = run_query

      # convert to hash format for readability
      actor_hashes = as_hashes(actors)

      # movies set to true will show all movies
      if show_movies

        # build actors_ids array so it can pass into second SQL query to search for genres.
        actor_ids = actor_ids(actors)

        # pass actors_hashes as reference. Fill Movies class will append actors genres.
        ActorServices::FillMovies.new(actor_hashes, actor_ids).run

      end

      actor_hashes
    end

    def actor_ids(actors)
      # this is to put actor_ids into an array
      actors.pluck('id')
    end

    def run_query

      @run_query ||= ActiveRecord::Base.connection.execute(query)

    end

    def as_hashes(actors)
      actors.map do |actor|
      {
          'id' => actor['id'],
          'first' => actor['first'],
          'last' => actor['last'],
          'sex' => actor['sex'],
          'dob' => actor['dob'],
          'dod' => actor['dod'],
          'movies_acted_in' => []
      }
      end
    end

    # probably a good idea to use ActiveRecord but let's just do SQL query to show what we can do.
    def query
      query = <<~HEREDOC
        SELECT *
        FROM Actors a
        WHERE (LOWER(a.first) LIKE LOWER(?) OR LOWER(?) IS NULL)
        AND (LOWER(a.last) LIKE LOWER(?) OR LOWER(?) IS NULL)
        AND (LOWER(a.sex) = LOWER(?) OR LOWER(?) IS NULL)
        AND (a.dob = ? OR ? IS NULL)
        AND (a.dod = ? OR ? IS NULL)
      HEREDOC

      ActiveRecord::Base.send(:sanitize_sql, [query, "%#{first_name}%", "%#{first_name}%", "%#{last_name}%", "%#{last_name}%", sex, sex, date_of_birth, date_of_birth, date_of_death, date_of_death])
    end
  end
end

