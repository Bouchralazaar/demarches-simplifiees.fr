describe WebhookController, type: :controller do
  describe '#helpscout' do
    before do
      allow(controller).to receive(:verify_signature!).and_return(true)
      allow(controller).to receive(:verify_authenticity_token)
    end

    subject(:response) { get :helpscout, params: { customer: { email: customer_email } } }

    let(:payload) { JSON.parse(subject.body) }
    let(:customer_email) { 'a-user@exemple.fr' }

    it "doesn't verify authenticity token" do
      subject
      expect(controller).not_to have_received(:verify_authenticity_token)
    end

    context 'when there is no matching user' do
      let(:customer_email) { 'not-a-user@exemple.fr' }

      it 'returns an empty response' do
        expect(subject.status).to eq(404)
        expect(subject.body).to be_empty
      end
    end

    context 'when there is a matching user' do
      let(:user) { create(:user, :with_strong_password) }
      let(:customer_email) { user.email }

      it 'returns a 200 response' do
        expect(subject.status).to eq(200)
        expect(subject.body).to be_present
      end

      it 'returns a link to the User profile in the Manager' do
        expect(payload).to have_key('html')
        expect(payload['html']).to have_selector("a[href='#{manager_user_url(user)}']")
      end

      context 'when there are an associated Instructeur and Administrateur' do
        let!(:instructeur) { create(:instructeur,    user: user) }
        let!(:admin)       { create(:administrateur, user: user, instructeur: instructeur) }

        it 'returns a link to the Instructeur profile in the Manager' do
          expect(payload).to have_key('html')
          expect(payload['html']).to have_selector("a[href='#{manager_instructeur_url(instructeur)}']")
        end

        it 'returns a link to the Administrateur profile in the Manager' do
          expect(payload).to have_key('html')
          expect(payload['html']).to have_selector("a[href='#{manager_administrateur_url(admin)}']")
        end
      end
    end
  end
end
