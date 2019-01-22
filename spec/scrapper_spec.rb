# require_relative '../lib/app/scrapper'

# describe "the get_townhall_email method" do

# 	it "should return an array" do
# 		expect(get_townhall_email(get_townhall_urls)).is_a?(Array)
# 	end
# 	it "should return a hash in the array" do
# 		expect(get_townhall_email(get_townhall_urls)[1]).is_a?(Hash)
# 	end

# 	it "should return a hash, and the hash is not nil" do
# 		expect(get_townhall_email(get_townhall_urls)).not_to be_nil
# 	end

# 	it "should contain some emails" do
# 		expect(get_townhall_email(get_townhall_urls)[-1]["Wy-dit-joli-village"]).to eq("mairie.wy-dit-joli-village@wanadoo.fr")
# 		expect(get_townhall_email(get_townhall_urls)[-7]["Villaines-sous-bois"]).to eq("mairie@villaines-sous-bois.fr")
# 	end
# end
