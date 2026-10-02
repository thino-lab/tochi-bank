module Portal
  class ProposalsController < BaseController
    def index
      @proposals = visible_proposals.includes(:land).order(created_at: :desc)
    end

    def show
      @proposal = visible_proposals.includes(:land).find(params[:id])
      LandProposals::Respond.new(@proposal).mark_viewed!
    end

    def react
      proposal = visible_proposals.find(params[:id])
      LandProposals::Respond.new(proposal).react!(params[:reaction])
      redirect_to portal_proposal_path(params[:token], proposal), notice: "ご回答ありがとうございます"
    rescue ArgumentError
      redirect_to portal_proposal_path(params[:token], proposal)
    end
  end
end
