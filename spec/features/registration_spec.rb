describe "registration", type: :feature do
  let(:member) do
    Member.create!(first_name: "Test", last_name: "Member", email: "member@email.com", membership_type: "RD")
  end

  before { visit registration_path }

  it "membership status check button redirects to member search" do
    click_link "Check Current Membership Status"
    expect(page).to have_current_path(member_search_path)
  end

  context "existing member" do
    it "shows a message that member is already registered" do
      find_by_id("first_name").fill_in(with: member.first_name)
      find_by_id("last_name").fill_in(with: member.last_name)
      find_by_id("email").fill_in(with: member.email)
      find_by_id("rd").click
      click_button "Pay Now"
      expect(page).to have_content "Your membership is already active for the current year"
    end
  end

  context "expired member" do
    before do
      member.update(membership_expiration_date: 1.day.ago)
    end

    it "displays the total payment due" do
      find_by_id("first_name").fill_in(with: member.first_name)
      find_by_id("last_name").fill_in(with: member.last_name)
      find_by_id("email").fill_in(with: member.email)
      find_by_id("rd").click
      click_button "Pay Now"
      expect(page).to have_content "Total: $35"
    end
  end

  context "new member" do
    before do
      find_by_id("first_name").fill_in(with: "New")
      find_by_id("last_name").fill_in(with: "Member")
      find_by_id("email").fill_in(with: "new@member.test")
    end

    context "RDN" do
      before { find_by_id("rd").click }

      it "displays the total payment due" do
        click_button "Pay Now"
        expect(page).to have_content "Total: $35"
      end

      it "does not offer sliding scale payment" do
        expect(page).to_not have_content("I would like to (anonymously) pay less than $35")
        expect(page).not_to have_selector("#sliding-scale")
      end

      context "when 'sponsor a student member' is selected" do
        before { find_by_id("sponsor-a-student").click }

        it "displays the total payment due" do
          click_button "Pay Now"
          expect(page).to have_content "Total: $45"
        end

        it "does not offer sliding scale payment" do
          expect(page).to_not have_content("I would like to (anonymously) pay less than $35")
          expect(page).not_to have_selector("#sliding-scale")
        end
      end
    end

    context "student" do
      before do
        find_by_id("student").click
      end

      it "displays the total payment due" do
        click_button "Pay Now"
        expect(page).to have_content "Total: $10"
      end

      it "does not allow student sponsorship" do
        expect(page).to_not have_content("I would like to sponsor a Student's membership for just $10 more")
      end

      it "does not offer sliding scale payment" do
        expect(page).to_not have_content("I would like to (anonymously) pay less than $35")
        expect(page).not_to have_selector("#sliding-scale")
      end
    end

    context "when offer_sliding_scale_membership_pricing setting is enabled" do
      before do
        Setting.instance.update!(offer_sliding_scale_membership_pricing: true)
        visit registration_path
      end

      context "RDN" do
        before { find_by_id("rd").click }

        it "displays the total payment due" do
          click_button "Pay Now"
          expect(page).to have_content "Total: $35"
        end

        it "offers sliding scale membership pricing" do
          expect(page).to have_content("I would like to (anonymously) pay less than $35")
        end

        context "when 'sponsor a student member' is selected" do
          before { find_by_id("sponsor-a-student").click }

          it "displays the total payment due" do
            click_button "Pay Now"
            expect(page).to have_content "Total: $45"
          end

          it "does not offer sliding scale payment" do
            expect(page).to_not have_content("I would like to (anonymously) pay less than $35")
            expect(page).not_to have_selector("#sliding-scale")
          end
        end

        context "when sliding scale payment is selected" do
          before do
            find_by_id("sliding-scale").click
          end

          it "has a working slider" do
            expect(page).to have_content("Choose an amount $20 - $35")
            find(".MuiSlider-thumb").drag_to(first(".MuiSlider-markLabel"))
            click_button "Pay Now"
            expect(page).to have_content "Total: $20"
          end

          it "does not allow student sponsorship" do
            expect(page).to_not have_content("I would like to sponsor a Student's membership for just $10 more")
          end
        end
      end

      context "student" do
        before do
          find_by_id("student").click
        end

        it "displays the total payment due" do
          click_button "Pay Now"
          expect(page).to have_content "Total: $10"
        end

        it "does not allow student sponsorship" do
          expect(page).to_not have_content("I would like to sponsor a Student's membership for just $10 more")
        end

        it "does not offer sliding scale payment" do
          expect(page).to_not have_content("I would like to (anonymously) pay less than $35 due to financial hardship")
        end
      end
    end
  end
end