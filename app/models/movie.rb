class Movie < ActiveRecord::Base
  def self.all_ratings
    %w(G PG PG-13 NC-17 R NA)
  end
  
class Movie::InvalidKeyError < StandardError ; end
  
  def self.find_in_tmdb(string)
    Tmdb::Api.key("f4702b08c0ac6ea5b51425788bb26562")
    begin
      @moviesReturnedFromSearch = Tmdb::Movie.find(string)
      @arrayToReturn=[]
      @currentMovieRating = nil
      if @moviesReturnedFromSearch != nil
        @moviesReturnedFromSearch.each do |movie|
          Tmdb::Movie.releases(movie.id)["countries"].each do |results|
            if results["iso_3166_1"] == "US"
              @currentMovieRating = results["certification"]
            end
          end
          if @currentMovieRating.to_s.strip.length == 0 
            @currentMovieRating = "NA"
          end
          @arrayToReturn << {:title => movie.title, :rating => @currentMovieRating, :tmdb_id => movie.id, :release_date => movie.release_date} 
        end
      end
      return @arrayToReturn
    rescue Tmdb::InvalidApiKeyError
      raise Movie::InvalidKeyError, 'Invalid API key'
    end
  end

  def self.create_from_tmdb(tmdb_id)
    Tmdb::Api.key("f4702b08c0ac6ea5b51425788bb26562")
    begin
      @movieRating = nil
      @movie = Tmdb::Movie.detail(tmdb_id)
      Tmdb::Movie.releases(tmdb_id)["countries"].each do |results|
        if results["iso_3166_1"] == "US"
          @movieRating = results["certification"]
        end
      end
      if @movieRating.to_s.strip.length == 0
        @movieRating = "NA"
      end
      @movieAttributes = {:title=> @movie["title"], :release_date=> @movie["release_date"], :rating => @movieRating, :description => @movie["overview"]}
      Movie.create!(@movieAttributes)
    rescue Tmdb::InvalidApiKeyError
      raise Movie::InvalidKeyError, 'Invalid API key'
    end
  end
end
