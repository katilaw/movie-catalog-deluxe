class Movies
	attr_reader :id, :title, :year, :rating, :genre, :studio, :actors

  def initialize(params={})
    @id = params["id"]
    @title = params["title"]
    @year = params["year"]
    @rating = params["rating"]
    @genre = params["genre"]
    @studio = params["studio"]
    @actors = []
  end

  def self.all
    movies = []
    movies = db_connection { |conn| conn.exec("SELECT movies.id, movies.title, movies.year, movies.rating, genres.name AS genre, studios.name AS studio
    FROM movies
    LEFT JOIN genres
    ON (movies.genre_id = genres.id )
    LEFT JOIN studios
    ON ( movies.studio_id = studios.id )
    ORDER BY movies.title") }
    movies.map { |movie| Movies.new(movie) }
  end

  def actors
      @actors = db_connection { |conn| conn.exec("SELECT actors.id, actors.name AS actor_name, cast_members.character AS character_name
			FROM cast_members
			LEFT JOIN movies
			ON (cast_members.movie_id = movies.id )
			LEFT JOIN actors
			ON (cast_members.actor_id = actors.id )
			WHERE movies.id = ($1)
      ORDER BY actors.name", [id]) }
  end
end
