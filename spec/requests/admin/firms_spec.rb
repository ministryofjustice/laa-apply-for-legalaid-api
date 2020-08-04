require 'rails_helper'

module Admin
  RSpec.describe FirmsController, type: :request do
    let(:admin_user) { create :admin_user }
    let!(:firms) { create_list :firm, 3 }

    before { sign_in admin_user }

    describe 'GET admin/firms' do
      before { get admin_firms_path }

      it 'renders successfully' do
        expect(response).to have_http_status(:ok)
      end

      it 'displays page heading' do
        expect(response.body).to include('List of firms')
      end

      it 'the name of every firm' do
        expect(response.body).to include(firms[0].name)
        expect(response.body).to include(firms[1].name)
        expect(response.body).to include(firms[2].name)
      end
    end
  end
end
