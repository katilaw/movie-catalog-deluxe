class Actors
	attr_reader :name, :id, :movies

  def initialize(params={})
    @id = params["id"]
    @name = params["name"]
    @movies = []
  end

  def self.all
    actors = []
    actors = db_connection { |conn| conn.exec("SELECT id, name FROM actors ORDER BY name") }
    actors.map { |actors| Actors.new(actors) }
  end

  def movies
      @movies = db_connection { |conn| conn.exec("SELECT movies.id, cast_members.character, movies.title
      FROM cast_members
      LEFT JOIN actors
      ON (actors.id = cast_members.actor_id )
      LEFT JOIN movies
      ON ( cast_members.movie_id = movies.id)
      WHERE actors.name = ($1)", [name]) }
  end

end
