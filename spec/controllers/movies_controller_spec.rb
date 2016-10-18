require 'spec_helper'
require 'rails_helper'

describe MoviesController do
  describe 'searching TMDb' do
   it 'should call the model method that performs TMDb search' do
      fake_results = [double('movie1'), double('movie2')]
      expect(Movie).to receive(:find_in_tmdb).with('Ted').
        and_return(fake_results)
      post :search_tmdb, {:search_terms => 'Ted'}
    end
    it 'should select the Search Results template for rendering' do
      allow(Movie).to receive(:find_in_tmdb)
      post :search_tmdb, {:search_terms => 'Ted'}
      expect(response).to render_template('search_tmdb')
    end  
    it 'should make the TMDb search results available to that template' do
      fake_results = [double('Movie'), double('Movie')]
      allow(Movie).to receive(:find_in_tmdb).and_return (fake_results)
      post :search_tmdb, {:search_terms => 'Ted'}
      expect(assigns(:movies)).to eq(fake_results)
    end
    it 'should check for invalid search terms then notify user' do
      fake_results = [double('Movie'), double('Movie')]
      allow(Movie).to receive(:find_in_tmdb).and_return (fake_results)
      post :search_tmdb, {:search_terms => ''}
      expect(flash[:notice]).to eq("Invalid search term")
    end 
    it 'should redirect the user if invalid search' do
      fake_results = [double('Movie'), double('Movie')]
      allow(Movie).to receive(:find_in_tmdb).and_return (fake_results)
      post :search_tmdb, {:search_terms => ''}
      expect(response).to redirect_to(movies_path)
    end
    it 'should check for no match from search then notify user' do
      fake_results = []
      allow(Movie).to receive(:find_in_tmdb).and_return (fake_results)
      post :search_tmdb, {:search_terms => 'movie title with no match'}
      expect(flash[:notice]).to eq("No matching movies were found on TMDb")
    end
    it 'should redirect the user if no match for search terms' do
      fake_results = []
      allow(Movie).to receive(:find_in_tmdb).and_return (fake_results)
      post :search_tmdb, {:search_terms => 'Ted'}
      expect(response).to redirect_to(movies_path)
    end 
    it 'should create two instance variables for communication with the view' do
      fake_results = 'test'
      allow(Movie).to receive(:find_in_tmdb).and_return (fake_results)
      post :search_tmdb, {:search_terms => 'test'}
      expect(assigns(:search_terms)).to eq 'test'
      expect(assigns(:movies)).to eq 'test'
    end
  end
  
  describe 'adding from TMDb' do
    it 'should flash a message for no movies selected' do
      expect(Movie).not_to receive(:create_from_tmdb)
      post :add_tmdb, {:tmdb_movies => nil}
      expect(flash[:notice]).to eq 'No movies selected'
      expect(response).to redirect_to(movies_path)
    end
    it 'should flash a message for successful addition' do
      movie = {double("movie") => 0}
      expect(Movie).to receive(:create_from_tmdb)
      post :add_tmdb, {:tmdb_movies => movie}
      expect(flash[:notice]).to eq 'Movies successfully added to Rotten Potatoes'
      expect(response).to redirect_to(movies_path)
    end
    it 'should add all movies checked by user' do
      movies = {"tmdb_movies" => {"203765"=>"on", "376659"=>"on", "9737"=>"on"}}
      expect(Movie).to receive(:create_from_tmdb).exactly(3).times
      post :add_tmdb, movies
    end
  end
end
