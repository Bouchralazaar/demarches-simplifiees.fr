describe 'users/dossiers/etablissement.html.haml', type: :view do
  let(:etablissement) { create(:etablissement, :with_exercices) }
  let(:dossier) { create(:dossier, etablissement: etablissement) }
  let(:footer) { view.content_for(:footer) }

  before do
    sign_in dossier.user
    assign(:dossier, dossier)
    allow_any_instance_of(APIEntrepriseToken).to receive(:roles).and_return([])
    allow_any_instance_of(APIEntrepriseToken).to receive(:expired?).and_return(false)
  end

  subject! { render }

  it 'affiche les informations de l’établissement' do
    expect(rendered).to have_text(etablissement.siret)
  end

  context 'etablissement avec infos non diffusables' do
    let(:etablissement) { create(:etablissement, :with_exercices, :non_diffusable) }
    it "affiche uniquement le nom de l'établissement si infos non diffusables" do
      expect(rendered).to have_text(etablissement.entreprise_raison_sociale)
      expect(rendered).not_to have_text(etablissement.entreprise.forme_juridique)
    end
  end

  it 'prépare le footer' do
    expect(footer).to have_selector('footer')
  end

  context 'etablissement as degraded mode' do
    let(:etablissement) { Etablissement.create!(siret: '41816609600051') }

    it "affiche une notice avec un lien de vérification vers l'annuaire" do
      expect(rendered).to have_text(etablissement.siret)
      expect(rendered).to have_link("Vérifier dans l'annuaire des entreprises", href: "https://annuaire-entreprises\.data\.gouv\.fr/rechercher?terme=#{etablissement.siret}")
    end
  end
end
