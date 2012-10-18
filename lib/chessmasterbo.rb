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
		status = '1'
		savepiece(gameId, 'WhiteTower',		'A1', 'A1', status, userInfo)
		savepiece(gameId, 'WhiteHorse',		'B1', 'B1', status, userInfo)
		savepiece(gameId, 'WhiteBishop',	'C1', 'C1', status, userInfo)
		savepiece(gameId, 'WhiteQueen',		'D1', 'D1', status, userInfo)
		savepiece(gameId, 'WhiteKing',		'E1', 'E1', status, userInfo)
		savepiece(gameId, 'WhiteBishop',	'F1', 'F1', status, userInfo)
		savepiece(gameId, 'WhiteHorse',		'G1', 'G1', status, userInfo)
		savepiece(gameId, 'WhiteTower', 	'H1', 'H1', status, userInfo)
		savepiece(gameId, 'WhitePawn',		'A2', 'A2', status, userInfo)
		savepiece(gameId, 'WhitePawn',		'B2', 'B2', status, userInfo)
		savepiece(gameId, 'WhitePawn',		'C2', 'C2', status, userInfo)
		savepiece(gameId, 'WhitePawn',		'D2', 'D2', status, userInfo)
		savepiece(gameId, 'WhitePawn',		'E2', 'E2', status, userInfo)
		savepiece(gameId, 'WhitePawn',		'F2', 'F2', status, userInfo)
		savepiece(gameId, 'WhitePawn',		'G2', 'G2', status, userInfo)
		savepiece(gameId, 'WhitePawn',		'H2', 'H2', status, userInfo)
	end

	def loadchessboardblack(gameId, userInfo)
		status = '1'
		savepiece(gameId, 'BlackTower', 	'A8', 'A8', status, userInfo)
		savepiece(gameId, 'BlackHorse', 	'B8', 'B8', status, userInfo)
		savepiece(gameId, 'BlackBishop',	'C8', 'C8', status, userInfo)
		savepiece(gameId, 'BlackQueen', 	'D8', 'D8', status, userInfo)
		savepiece(gameId, 'BlackKing', 		'E8', 'E8', status, userInfo)
		savepiece(gameId, 'BlackBishop', 	'F8', 'F8', status, userInfo)
		savepiece(gameId, 'BlackHorse', 	'G8', 'G8', status, userInfo)
		savepiece(gameId, 'BlackTower', 	'H8', 'H8', status, userInfo)
		savepiece(gameId, 'BlackPawn',		'A7', 'A7', status, userInfo)
		savepiece(gameId, 'BlackPawn',		'B7', 'B7', status, userInfo)
		savepiece(gameId, 'BlackPawn',		'C7', 'C7', status, userInfo)
		savepiece(gameId, 'BlackPawn',		'D7', 'D7', status, userInfo)
		savepiece(gameId, 'BlackPawn',		'E7', 'E7', status, userInfo)
		savepiece(gameId, 'BlackPawn',		'F7', 'F7', status, userInfo)
		savepiece(gameId, 'BlackPawn',		'G7', 'G7', status, userInfo)
		savepiece(gameId, 'BlackPawn',		'H7', 'H7', status, userInfo)
	end

	def updatechessboard(gameId, piece, origin, final)
		status = '1'
		piece1 = Chessboard.where(:gameId => gameId, :piece => piece, :final => origin, :status => '1').first		

		if piece1
			piece2 = Chessboard.where(:gameId => gameId, :final => final, :status => '1').first
			if piece2
				piece2.update_attributes(						
						:status 		=> '0',
						:lastModified	=> Time.now.to_s
					)
			end
			#TODO: Validate final position
			game = Game.where(:gameId => gameId).first
			game.update_attributes(
				:lastMove 			=> Time.now.to_s
				)

			piece1.update_attributes(
					:origin			=> origin,
					:final			=> final,
					:status 		=> status,
					:lastModified	=> Time.now.to_s
				)
			olist = Chessboard.where(:gameId => gameId).all(:order => :item.asc)

			return writelisttojson(olist)

		else
			return 'ERROR'
		end

		
	end

	def savepiece(gameId, piece, initial, final, status, userInfo)
		chessboard = Chessboard.new
		chessboard.gameId		= gameId
		chessboard.playerId		= userInfo['id']
		chessboard.piece		= piece
		chessboard.origin		= initial
		chessboard.final		= final
		chessboard.status		= status # It should be 1 or 0
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