class EmailsController < ApplicationController
  require 'contextio'

  before_action :authenticate_user!

  def index
    contextio = ContextIO.new(current_user.contextio_key, current_user.contextio_secret)
    account = contextio.accounts.where(email: current_user.email).first
    # debugger
    @emails = account.messages.where(limit: 50)
  end
end
