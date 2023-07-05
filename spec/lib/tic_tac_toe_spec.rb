require_relative "../../lib/tic_tac_toe.rb"

RSpec.describe TicTacToe do
  let(:instance) { described_class.new }

  describe "initialization" do
    it "properties initialized correct" do
      expect(instance.instance_variable_get("@board")).to eq([["\e[0;31;49mX\e[0m", " ", " "], [" ", " ", " "], [" ", " ", " "]])
      expect(instance.instance_variable_get("@cursor_x")).to eq 0
      expect(instance.instance_variable_get("@cursor_y")).to eq 0
    end
  end

  describe "instance methods" do
    describe "#make_move" do
      subject(:make_move) { instance.make_move(signal) }

      context "when moving right" do
        let(:signal) { described_class::RIGHT_ARROW }

        it "moves cursor right" do
          make_move

          expect(instance.instance_variable_get("@board")).to eq([[" ", "\e[0;31;49mX\e[0m", " "], [" ", " ", " "], [" ", " ", " "]])
        end
      end

      context "when moving left" do
        let(:signal) { described_class::LEFT_ARROW }

        context "when it's not possible to move left" do
          it "moves cursor left" do
            make_move

            expect(instance.instance_variable_get("@board")).to eq([["\e[0;31;49mX\e[0m", " ", " "], [" ", " ", " "], [" ", " ", " "]])
          end
        end

        context "when it's possible to move left" do
          before do
            instance.make_move(described_class::RIGHT_ARROW)
            instance.make_move(described_class::DOWN_ARROW)
          end

          it "moves cursor left" do
            make_move

            expect(instance.instance_variable_get("@board")).to eq([[" ", " ", " "], ["\e[0;31;49mX\e[0m", " ", " "], [" ", " ", " "]])
          end
        end
      end

      context "when moving up" do
        let(:signal) { described_class::UP_ARROW }

        context "when it's not possible to move left" do
          it "moves cursor left" do
            make_move

            expect(instance.instance_variable_get("@board")).to eq([["\e[0;31;49mX\e[0m", " ", " "], [" ", " ", " "], [" ", " ", " "]])
          end
        end

        context "when it's possible to move up" do
          before do
            instance.make_move(described_class::RIGHT_ARROW)
            instance.make_move(described_class::DOWN_ARROW)
          end

          it "moves cursor left" do
            make_move

            expect(instance.instance_variable_get("@board")).to eq([[" ", "\e[0;31;49mX\e[0m", " "], [" ", " ", " "], [" ", " ", " "]])
          end
        end
      end

      context "when moving down" do
        let(:signal) { described_class::DOWN_ARROW }

        it "moves cursor down" do
          make_move

          expect(instance.instance_variable_get("@board")).to eq([[" ", " ", " "], ["\e[0;31;49mX\e[0m", " ", " "], [" ", " ", " "]])
        end
      end

      context "when doing smth else" do
        let(:signal) { "e" }

        it "does not do anything" do
          make_move

          expect(instance.instance_variable_get("@board")).to eq([["\e[0;31;49mX\e[0m", " ", " "], [" ", " ", " "], [" ", " ", " "]])
        end
      end
    end

    describe "#finished?" do
      subject(:finished?) { instance.finished? }

      context "when win" do
        before do
          allow(instance).to receive(:won?).and_return(true)
        end

        it { is_expected.to be_truthy }
      end

      context "when draw" do
        before do
          allow(instance).to receive(:draw?).and_return(true)
        end

        it { is_expected.to be_truthy }
      end

      context "when not win and not draw" do
        before do
          allow(instance).to receive(:won?).and_return(false)
          allow(instance).to receive(:draw?).and_return(false)
        end

        it { is_expected.to be_falsey }
      end
    end

    describe "#render" do
      subject(:render) { instance.render }

      context "when win" do
        before do
          allow(instance).to receive(:won?).and_return(true)
          instance.instance_variable_set("@last_player_played", described_class::PLAYER_O)
        end

        it "renders correct" do
          expect(Output).to receive(:write).with("\n\n\t\e[5;34;41mO\e[0m\e[5;34;41m WOOON!\nCongratulations!\e[0m \n\n").once

          render
        end
      end

      context "when draw" do
        before do
          allow(instance).to receive(:draw?).and_return(true)
        end

        it "renders correct" do
          expect(Output).to receive(:write).with("\n\n\t\e[5;34;41mIt's a DRAW. Good job!\e[0m\n\n").once

          render
        end
      end

      context "when not win and not draw" do
        it "renders correct" do
          expect(Output).to receive(:write).with("Current player is: X \n\r \e[0;31;49mX\e[0m |   |  \n\r---+---+---\n\r   |   |  \n\r---+---+---\n\r   |   |  \n\r").once

          render
        end
      end
    end

    describe "#commit_move" do
      subject(:commit_move) { instance.commit_move }

      context "when cell is occupied" do
        before do
          instance.instance_variable_set("@board", [["O\e[0;31;49mX\e[0m", " ", " "], [" ", " ", " "], [" ", " ", " "]])
          instance.instance_variable_set("@last_player_played", described_class::PLAYER_O)
          instance.instance_variable_set("@cursor_x", 0)
          instance.instance_variable_set("@cursor_y", 0)
        end

        it "does not do anything" do
          commit_move

          expect(instance.instance_variable_get("@board")).to eq([["O\e[0;31;49mX\e[0m", " ", " "], [" ", " ", " "], [" ", " ", " "]])
          expect(instance.instance_variable_get("@last_player_played")).to eq(described_class::PLAYER_O)
        end
      end

      context "when cell is not occupied" do
        it "does commits a move" do
          commit_move

          expect(instance.instance_variable_get("@board")).to eq([["X", " ", " "], [" ", " ", " "], [" ", " ", " "]])
          expect(instance.instance_variable_get("@last_player_played")).to eq(described_class::PLAYER_X)
        end
      end
    end
  end
end
