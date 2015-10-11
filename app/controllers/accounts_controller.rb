class AccountsController < ApplicationController

	def index
	end


	def conversation
		# Get the conversation based on id given

	end


	def add
		# Add an account
		
	end


	def edit
		# Edit an account
		
	end


	def schedule_meeting
		flash[:success] = 'Your meeting has been successfully scheduled'
		redirect_to accounts_conversation_path
	end 

	def add_note
		flash[:success] = 'Your note has been added to the conversation'
		redirect_to accounts_conversation_path
	end

	def send_email
		flash[:success] = 'Your email has been successfully sent'
		redirect_to accounts_conversation_path
	end




end
