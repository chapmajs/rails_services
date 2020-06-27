require 'rails_helper'

RSpec.describe ProcessPreorderService do
  let!(:preorder) { FactoryBot.build(:preorder_with_enabled_project) }
  let(:service) { ProcessPreorderService.new(preorder) }

  it 'should generate a confirmation token' do
    expect(preorder.confirmation_token).to be_blank
    service.execute
    expect(preorder.confirmation_token).to be_present
  end

  it 'should send a confirmation email' do
    expect_any_instance_of(PreorderMailer).to receive(:confirmation).with(preorder)
    service.execute
  end

  it 'should persist the preorder' do
    expect(preorder).not_to be_persisted
    service.execute
    expect(preorder).to be_persisted
  end

  it 'should strip all preorder fields' do
    preorder.name = '<b>The Name</b>'
    preorder.email = '<i>email@you.com</i>'
    preorder.boards = '<a href="http://www.bogus.com/">Totally Legit</a><script>Should go away</script>'

    service.execute

    expect(preorder.name).to eq 'The Name'
    expect(preorder.email).to eq 'email@you.com'
    expect(preorder.boards).to eq 'Totally Legit'
  end
end