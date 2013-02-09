# -*- encoding : utf-8 -*-

require "sinatra"
require 'koala'
require 'json'
load 'game.rb'

enable :sessions
set :raise_errors, true
set :show_exceptions, true

# Scope defines what permissions that we are asking the user to grant.
# In this example, we are asking for the ability to publish stories
# about using the app, access to what the user likes, and to be able
# to use their pictures.  You should rewrite this scope with whatever
# permissions your app needs.
# See https://developers.facebook.com/docs/reference/api/permissions/
# for a full list of permissions
FACEBOOK_SCOPE = 'user_likes,user_photos,user_photo_video_tags'

ENV["FACEBOOK_APP_ID"] = '289993544437260'
ENV["FACEBOOK_SECRET"] = 'b58030caeca308fb56211fcf84434678'

unless ENV["FACEBOOK_APP_ID"] && ENV["FACEBOOK_SECRET"]
  abort("missing env vars: please set FACEBOOK_APP_ID and FACEBOOK_SECRET with your app credentials")
end

before do 

  # HTTPS redirect
  if settings.environment == :production && request.scheme != 'https'
    redirect "https://#{request.env['HTTP_HOST']}"
  end
  
end

def IsUserLogin
  print "wake ma up, before you go go! :D"
  if 
	(session['userID'] == nil || 
	session[:access_token] == nil) then
	redirect '/you-have-to-login'
  end
end

helpers do
  def host
    request.env['HTTP_HOST']
  end

  def scheme
    request.scheme
  end

  def url_no_scheme(path = '')
    "//#{host}#{path}"
  end

  def url(path = '')
    "#{scheme}://#{host}#{path}"
  end

  def authenticator
    @authenticator ||= Koala::Facebook::OAuth.new(ENV["FACEBOOK_APP_ID"], ENV["FACEBOOK_SECRET"], url("/auth/facebook/callback"))
  end

end

# the facebook session expired! reset ours and restart the process
error(Koala::Facebook::APIError) do
  session[:access_token] = nil
  redirect "/auth/facebook"
end

get '/you-have-to-login' do 
	erb :you_have_to_login
end

get '/game/init/' do
	IsUserLogin()
	
	if File.exist?('./status/' + session['userID'].to_s + '.txt') == false then
		redirect '/api/init/'
	else
		redirect '/game'
	end
	
end

get '/api/init/' do
	
	IsUserLogin()
	
    # Get base API Connection
    @graph  = Koala::Facebook::API.new(session[:access_token])

    if session[:access_token]
		print "Pobieram user ID";
        @user    = @graph.get_object("me")
        session['userID'] = @user['id']
    end

    width = 20
    height = 20

    File.open('./status/' + session['userID'].to_s + '.txt', 'w') { |out|
        out.write width.to_s + "\n";
        out.write height.to_s + "\n";

        #  mapa
        map = ''
        count = width * height
        count.times do
            map = map + '0'
        end
        out.write map + "\n"

        #zanieczyszczenia
        out.write map + "\n"

        #popyt
        out.write map + "\n"

        #  budżet
        money = 100000;
        out.write money.to_s + "\n"

        #  budżet w przyszłości
        future = 100000;
        out.write future.to_s + "\n"

        #  popyt na strefę przemysłową
        out.write "8\n"

        #  popyt na strefę komercyjną
        out.write "8\n"

        #  popyt na strefę mieszkalną
        out.write "8\n"

        #  budynki specjalne
        count.times do
            out.write "0\n"
        end

        #  podatki
        out.write "9\n"
        out.write "9\n"
        out.write "9\n"

        #  liczba ludzi (mieszkańców lub miejsc pracy) w danym obszarze
        count.times do
            out.write "0\n"
        end

        out.close
    }
    
    redirect '/game'
end


get "/" do
	IsUserLogin()

  # Get base API Connection
  @graph  = Koala::Facebook::API.new(session[:access_token])

  # Get public details of current application
  @app  =  @graph.get_object(ENV["FACEBOOK_APP_ID"])

  if session[:access_token]
    @user    = @graph.get_object("me")
    @friends = @graph.get_connections('me', 'friends')
    @photos  = @graph.get_connections('me', 'photos')
    @likes   = @graph.get_connections('me', 'likes').first(4)

    # for other data you can always run fql
    @friends_using_app = @graph.fql_query("SELECT uid, name, is_app_user, pic_square FROM user WHERE uid in (SELECT uid2 FROM friend WHERE uid1 = me()) AND is_app_user = 1")
  end


  erb :index
end

get '/game' do
	IsUserLogin()
    @width = 20
    @height = 20
    erb :game
end

post '/api/start' do
    game = Game.new(session['userID']);
    JSON.generate(
        {
            'width' => game.width,
            'height' => game.height,
            'map' => game.map,
            'pollution' => game.pollution,
            'demand' => game.demand,
            'money' => game.money,
            'future' => game.future,
            'demandI' => game.demandI,
            'demandC' => game.demandC,
            'demandR' => game.demandR,
            'taxI' => game.taxI,
            'taxC' => game.taxC,
            'taxR' => game.taxR,
            'builds' => game.builds,
            'people' => game.people,
            'workPlace' => game.workPlace,
            'population' => game.population
        }
    )
end

post '/api/create-build' do
	game = Game.new(session['userID']);
    ok = game.buildSpecial(
            params['x'].to_i, 
            params['y'].to_i, 
            params['type'].to_i);
    
    JSON.generate({
        'ok' => ok,
        'money' => game.money,
        'future' => game.future
    })
end

post '/api/remove' do
	game = Game.new(session['userID']);
    game.remove(
			params['x'].to_i, 
			params['y'].to_i
		);
end

post '/api/power-status' do
	power = params['power']
	game = Game.new(session['userID']);
	i = 0
	(game.width * game.height).times do
		if power[i] == 'true' then
			game.demand[i] = 1
		else
			game.demand[i] = 0
		end
		i = i + 1
	end
    game.save();
end

post '/api/tax' do
	game = Game.new(session['userID']);
	print "aaaaaaaaaaaaaaaaaaa"
	print params['taxC']
	print "bbbbbbbbbbbbbb"
	print game.taxC
	print "cccccccccccccc"
	game.taxC = params['taxC'].to_f
	game.taxR = params['taxR'].to_f
	game.taxI = params['taxI'].to_f
	game.save()
end

post '/api/update' do
    game = Game.new(session['userID'])
    game.update()
    JSON.generate(
        {
            'map' => game.map,
            'pollution' => game.pollution,
            'demand' => game.demand,
            'money' => game.money,
            'future' => game.future,
            'demandI' => game.demandI,
            'demandC' => game.demandC,
            'demandR' => game.demandR,
            'people' => game.people,
            'workPlace' => game.workPlace,
            'population' => game.population,
            'tips' => game.tips.uniq
        }
    )
end

post "/api/create-road" do

    game = Game.new(session['userID'])
    canBuild = game.buildRoad(
        params['x_from'].to_i,
        params['y_from'].to_i,
        params['x_to'].to_i,
        params['y_to'].to_i);

    JSON.generate({
        'ok' => canBuild,
        'money' => game.money,
        'future' => game.future
    });
end

post "/api/create-area" do

    game = Game.new(session['userID']);
    game.buildArea(
        params['x_from'].to_i,
        params['y_from'].to_i,
        params['x_to'].to_i,
        params['y_to'].to_i,
        params['type'].to_i
    );

    JSON.generate({
        'money' => game.money,
        'future' => game.future
    });
end

# used by Canvas apps - redirect the POST to be a regular GET
post "/" do
  redirect "/"
end

# used to close the browser window opened to post to wall/send to friends
get "/close" do
  "<body onload='window.close();'/>"
end

get "/sign_out" do
  session[:access_token] = nil
  session['userID'] = nil
  redirect '/'
end

get "/auth/facebook" do
  session[:access_token] = nil
  redirect authenticator.url_for_oauth_code(:permissions => FACEBOOK_SCOPE)
end

get '/auth/facebook/callback' do
	session[:access_token] = authenticator.get_access_token(params[:code])
	
	@graph  = Koala::Facebook::API.new(session[:access_token])
	if session[:access_token]
		print "Pobieram user ID";
        @user    = @graph.get_object("me")
        session['userID'] = @user['id']
    end
	
	redirect '/game/init/'
end
