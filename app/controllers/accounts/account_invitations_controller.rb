class Accounts::AccountInvitationsController < ApplicationController
  before_action :set_account
  before_action :require_account_admin
  before_action :set_account_invitation, only: [:edit, :update, :destroy]

  def new
    @account_invitation = AccountInvitation.new
  end

  def create
    @account_invitation = AccountInvitation.new(invitation_params)
    if @account_invitation.save_and_send_invite
      redirect_to @account
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @account_invitation.update(invitation_params)
      redirect_to @account
    else
      render :edit
    end
  end

  def destroy
    @account_invitation.destroy
    redirect_to @account
  end

  private

  def set_account
    @account = current_user.accounts.find(params[:account_id])
  end

  def set_account_invitation
    @account_invitation = @account.account_invitations.find_by!(token: params[:id])
  end

  def invitation_params
    params
      .require(:account_invitation)
      .permit(:name, :email, AccountUser::ROLES)
      .merge(account: @account, invited_by: current_user)
  end

  def require_account_admin
    account_user = @account.account_users.find_by(user: current_user)
    unless account_user&.active_roles&.include?(:admin)
      redirect_to @account, alert: "Only account admins are allowed to do that."
    end
  end
end