require 'rubygems'
require 'sinatra'
require 'koala'
require 'mongo'
require 'json'
require 'mongo_mapper'
require 'uri'

require_relative 'chessuser'

class Chessmasterbo
	
	enable :sessions

	def verifyuser(userInfo, tokken)
		userId = userInfo['id']
		usr = ChessUser.where(:userId => userId).first
		if usr.nil?
			user = ChessUser.new
			user.userId				= userInfo['id']
			user.name 				= userInfo['name']		
			user.userName			= userInfo['username']
			user.email				= userInfo['email']
			user.tokken				= tokken
			user.creationDate		= Time.now.to_s
			user.save
		end		
	end

	def newgame(userInfo)
		
		uuid = UUID.new
		game = Game.new

		game.item				= Game.count + 1
		game.gameId	 			= uuid.generate
		game.player1Id			= userInfo['id']
		game.player1 			= userInfo['name']		
		game.player1UserName	= userInfo['username']
		game.player1Email		= userInfo['email']
		game.creationDate		= Time.now.to_s
		game.status				= 'New'
		game.url     			= 'http://fb-chess.herokuapp.com/see?game=' +  game.gameId		
		game.save

		return game

	end

	def loadchessboardwhite(gameId, userInfo)
		# Load chessboard 
		savepiece(gameId, 'BlackTower',		'A1', 'A1', userInfo)
		savepiece(gameId, 'BlackHorse',		'B1', 'B1', userInfo)
		savepiece(gameId, 'BlackBishop',	'C1', 'C1', userInfo)
		savepiece(gameId, 'BlackQueen',		'D1', 'D1', userInfo)
		savepiece(gameId, 'BlackKing',		'E1', 'E1', userInfo)
		savepiece(gameId, 'BlackBishop',	'F1', 'F1', userInfo)
		savepiece(gameId, 'BlackHorse',		'G1', 'G1', userInfo)
		savepiece(gameId, 'BlackTower', 	'H1', 'H1', userInfo)
		savepiece(gameId, 'BlackPawn',		'A2', 'A2', userInfo)
		savepiece(gameId, 'BlackPawn',		'B2', 'B2', userInfo)
		savepiece(gameId, 'BlackPawn',		'C2', 'C2', userInfo)
		savepiece(gameId, 'BlackPawn',		'D2', 'D2', userInfo)
		savepiece(gameId, 'BlackPawn',		'E2', 'E2', userInfo)
		savepiece(gameId, 'BlackPawn',		'F2', 'F2', userInfo)
		savepiece(gameId, 'BlackPawn',		'G2', 'G2', userInfo)
		savepiece(gameId, 'BlackPawn',		'H2', 'H2', userInfo)
	end

	def loadchessboardblack(gameId, userInfo)
		savepiece(gameId, 'WhiteTower', 	'A8', 'A8', userInfo)
		savepiece(gameId, 'WhiteHorse', 	'B8', 'B8', userInfo)
		savepiece(gameId, 'WhiteBishop',	'C8', 'C8', userInfo)
		savepiece(gameId, 'WhiteQueen', 	'D8', 'D8', userInfo)
		savepiece(gameId, 'WhiteKing', 		'E8', 'E8', userInfo)
		savepiece(gameId, 'WhiteBishop', 	'F8', 'F8', userInfo)
		savepiece(gameId, 'WhiteHorse', 	'G8', 'G8', userInfo)
		savepiece(gameId, 'WhiteTower', 	'H8', 'H8', userInfo)
		savepiece(gameId, 'WhitePawn',		'A7', 'A7', userInfo)
		savepiece(gameId, 'WhitePawn',		'B7', 'B7', userInfo)
		savepiece(gameId, 'WhitePawn',		'C7', 'C7', userInfo)
		savepiece(gameId, 'WhitePawn',		'D7', 'D7', userInfo)
		savepiece(gameId, 'WhitePawn',		'E7', 'E7', userInfo)
		savepiece(gameId, 'WhitePawn',		'F7', 'F7', userInfo)
		savepiece(gameId, 'WhitePawn',		'G7', 'G7', userInfo)
		savepiece(gameId, 'WhitePawn',		'H7', 'H7', userInfo)
	end

	def updatechessboard(gameId, piece, origin, final)

		chessboard = Chessboard.where(:gameId => gameId, :piece => piece, :final => origin).first

		chessboard.update_attributes(
				:origin			=> origin,
				:final			=> final,
				:lastModified	=> Time.now.to_s
			)
		
		olist = Chessboard.all(:order => :item.asc)

		return writelisttojson(olist)
	end

	def savepiece(gameId, piece, initial, final, userInfo)
		chessboard = Chessboard.new
		chessboard.gameId		= gameId
		chessboard.playerId		= userInfo['id']
		chessboard.piece		= piece
		chessboard.origin		= initial
		chessboard.final		= final
		chessboard.save
	end

	def challenge(gameId, userInfo)
		game = Game.where(:gameId => gameId).first
		game.update_attributes(
			:player2 			=> userInfo['name'],
			:player2Id 			=> userInfo['id'],
			:player2UserName	=> userInfo['username'],
			:player2Email 		=> userInfo['email'],
			:currentPlayer 		=> game.player1,
			:currentPlayerId 	=> game.player1Id,
			:status 			=> 'In Progress'
			)
	end

	def putwallpost(access_token, message)
		@graph = Koala::Facebook::GraphAPI.new(access_token)
		@graph.put_wall_post(message)
	end


	def writelisttojson(olist)
		result = ''
		olist.each do |item|
			result = result + item.to_json.to_s
		end
		return result
	end

end