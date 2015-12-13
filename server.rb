require "sinatra"
require "pg"
require_relative "./app/models/actors"
require_relative "./app/models/movies"
require 'pry'

set :views, File.join(File.dirname(__FILE__), "app/views")

configure :development do
  set :db_config, { dbname: "movies" }
end

configure :test do
  set :db_config, { dbname: "movies_test" }
end

def db_connection
  begin
    connection = PG.connect(Sinatra::Application.db_config)
    yield(connection)
  ensure
    connection.close
  end
end

get '/actors' do
  @actors = Actors.all
  erb :'index/actors'
end

get '/actors/:id' do
  actor_temp = retrieve_actor(params[:id])
  @actor = Actors.new(actor_temp[0])
  @actor_details = @actor.movies
  erb :'actor_roles'
end

get '/actors' do
  @actors = Actors.all
  erb :'index/actors'
end

get '/movies' do
  @movies = Movies.all
  erb :'index/movies'
end

get '/movies/:id' do
  movie_temp = retrieve_movie(params[:id])
  @movie = Movies.new(movie_temp[0])
  @movie_actors = @movie.actors
  erb :'movie_info'
end

def retrieve_actor(id)
  db_connection { |conn| conn.exec("SELECT id, name FROM actors WHERE actors.id = ($1)", [id]) }
end

def retrieve_movie(id)
  db_connection { |conn| conn.exec("SELECT movies.id, movies.title, movies.year, movies.rating, genres.name AS genre, studios.name AS studio
  FROM movies
  LEFT JOIN genres
  ON (movies.genre_id = genres.id )
  LEFT JOIN studios
  ON ( movies.studio_id = studios.id )
  WHERE movies.id = ($1)", [id]) }
end
