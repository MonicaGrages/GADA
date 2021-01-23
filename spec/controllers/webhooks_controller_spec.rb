RSpec.describe WebhooksController, type: :controller do
  describe "create" do
    let(:item_name) { "RD" }
    let(:payment_status) { "Completed" }
    let(:receiver_email) { "treasurer@eatrightatlanta.org" }
    let(:txn_id) { "txn-1" }
    let(:payer_email) { "member@email.com" }
    let(:params) do
      {
        mc_gross: "46.70",
        protection_eligibility: "Eligible",
        address_status: "confirmed",
        payer_id: "12345",
        address_street: "12345 Main St",
        payment_date: "11:27:20 Jan 09, 2021 PST",
        payment_status: payment_status,
        charset: "windows-1252",
        address_zip: "30045",
        first_name: "First",
        mc_fee: "1.65",
        address_country_code: "US",
        address_name: "First Last",
        notify_version: "3.9",
        payer_status: "verified",
        business: "treasurer@eatrightatlanta.org",
        address_country: "United States",
        address_city: "Atlanta",
        quantity: "1",
        verify_sign: "12345-asdf",
        payer_email: payer_email,
        txn_id: txn_id,
        payment_type: "instant",
        last_name: "Last",
        address_state: "GA",
        receiver_email: receiver_email,
        payment_fee: "1.65",
        shipping_discount: "0.00",
        insurance_amount: "0.00",
        receiver_id: "12345",
        txn_type: "express_checkout",
        item_name: item_name,
        discount: "0.00",
        mc_currency: "USD",
        item_number: "",
        residence_country: "US",
        shipping_method: "Default",
        transaction_subject: "RD",
        payment_gross: "46.70",
        ipn_track_id: "12345",
      }
    end
    let(:notification_status) { "VERIFIED" }
    let(:fake_response) {instance_double(Net::HTTPResponse, body: notification_status) }

    subject { post :create, params: params }

    before do
      allow_any_instance_of(Net::HTTP).to receive(:post).and_return(fake_response)
      allow_any_instance_of(Member).to receive(:subscribe_to_mailchimp)
    end

    it "validates IPN response" do
      expect_any_instance_of(Net::HTTP).to receive(:post).and_return(fake_response)
      subject
    end

    it "is successful" do
      subject
      expect(response).to be_successful
    end

    it "creates a PaymentTransaction" do
      expect { subject }.to change { PaymentTransaction.count }.by(1)
    end

    it "creates a Member" do
      expect { subject }.to change { Member.count }.by(1)
    end

    context "when member already exists" do
      let!(:member) { Member.create!(email: payer_email, first_name: "First", last_name: "Last", membership_type: "RD") }

      it "is successful" do
        subject
        expect(response).to be_successful
      end

      it "does not create a Member" do
        expect { subject }.not_to change { Member.count }
      end

      it "creates a PaymentTransaction" do
        expect { subject }.to change { PaymentTransaction.count }.by(1)
      end

      context "when membership is expired" do
        before { member.update(membership_expiration_date: 1.month.ago) }

        it "is successful" do
          subject
          expect(response).to be_successful
        end

        it "renews membership expiration" do
          expect { subject }.to change { member.reload.membership_expiration_date }
          expect(member.expired?).to be_falsey
        end

        it "does not create a Member" do
          expect { subject }.not_to change { Member.count }
        end

        it "creates a PaymentTransaction" do
          expect { subject }.to change { PaymentTransaction.count }.by(1)
        end
      end
    end

    context "when payment has not been completed" do
      let(:payment_status) { "Incomplete" }

      it "is successful" do
        subject
        expect(response).to be_successful
      end

      it "creates a PaymentTransaction" do
        expect { subject }.not_to change { PaymentTransaction.count }
      end

      it "does not create a Member" do
        expect { subject }.not_to change { Member.count }
      end
    end

    context "when receiver_email does not match expected value" do
      let(:receiver_email) { "SomebodyElse@email.com" }

      it "is successful" do
        subject
        expect(response).to be_successful
      end

      it "does creates a PaymentTransaction" do
        expect { subject }.to change { PaymentTransaction.count }.by(1)
      end

      it "does not create a Member" do
        expect { subject }.not_to change { Member.count }
      end
    end

    context "when transaction is a duplicate" do
      let!(:previous_transaction) { PaymentTransaction.create!(payload: params, transaction_status: "verified") }

      it "is successful" do
        subject
        expect(response).to be_successful
      end

      it "does not create a PaymentTransaction" do
        expect { subject }.not_to change { PaymentTransaction.count }
      end

      it "does not create a Member" do
        expect { subject }.not_to change { Member.count }
      end

      context "when previous notification could not be verified" do
        let!(:previous_transaction) { PaymentTransaction.create!(payload: params, transaction_status: "invalid") }

        it "is successful" do
          subject
          expect(response).to be_successful
        end

        it "creates a PaymentTransaction" do
          expect { subject }.to change { PaymentTransaction.count }.by(1)
        end

        it "creates a Member" do
          expect { subject }.to change { Member.count }.by(1)
        end
      end
    end

    context "when notification verification response is invalid" do
      let(:notification_status) { "INVALID" }

      it "is successful" do
        subject
        expect(response).to be_successful
      end

      it "creates a PaymentTransaction" do
        expect { subject }.to change { PaymentTransaction.count }.by(1)
      end

      it "does not create a Member" do
        expect { subject }.not_to change { Member.count }
      end
    end

    context "when notification verification response is unrecognized" do
      let(:notification_status) { "OTHER" }

      it "is successful" do
        subject
        expect(response).to be_successful
      end

      it "creates a PaymentTransaction" do
        expect { subject }.to change { PaymentTransaction.count }.by(1)
      end

      it "does not create a Member" do
        expect { subject }.not_to change { Member.count }
      end
    end

  end
end