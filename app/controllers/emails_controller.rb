class EmailsController < ApplicationController
  require 'contextio'

  before_action :authenticate_user!

  def index
    contextio = ContextIO.new(CONTEXTIO_KEYS[current_user.email][:key], CONTEXTIO_KEYS[current_user.email][:secret])
    account = contextio.accounts.where(email: current_user.email).first
    # debugger
    @emails = account.messages.where(limit: 50)
  end
end
