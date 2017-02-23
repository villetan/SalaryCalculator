require 'rails_helper'

describe FileHelper, type: :helper do
  describe "Method" do

    it " -overtime_salary works correctly" do
      expect(send(:overtime_salary, 8.5)).to eq ((0.5 * 0.25 * 3.75).round(2))
      expect(send(:overtime_salary, 10.5)).to eq (((2 * 0.25 * 3.75) + (0.5 * 0.5 * 3.75)).round(2))
      expect(send(:overtime_salary, 12.5)).to eq (((2 * 0.25 * 3.75) + (2 * 0.5 * 3.75) + (0.5 * 3.75)).round(2))
      expect(send(:overtime_salary, 8)).to eq (0)
      expect(send(:overtime_salary, 5)).to eq (0)
    end

    it " -evening_salary work correctly" do
      start1 = Time.new(2014, 10, 31, 18)
      end1 = Time.new(2014, 11, 1, 6)
      expect(send(:evening_salary, start1, end1)).to eq(13.80)
      start1 = Time.new(2014, 10, 31, 20)
      end1 = Time.new(2014, 10, 31, 23)
      expect(send(:evening_salary, start1, end1)).to eq(3.45)
      start1 = Time.new(2014, 10, 31, 15)
      end1 = Time.new(2014, 10, 31, 19)
      expect(send(:evening_salary, start1, end1)).to eq(1.15)
      start1 = Time.new(2014, 10, 31, 16)
      end1 = Time.new(2014, 10, 31, 8)
      expect(send(:evening_salary, start1, end1)).to eq(0.00)
      start1 = Time.new(2014, 10, 31, 0)
      end1 = Time.new(2014, 10, 31, 8)
      expect(send(:evening_salary, start1, end1)).to eq((6 * 1.15).round(2))
      start1 = Time.new(2014, 10, 31, 5)
      end1 = Time.new(2014, 10, 31, 19)
      expect(send(:evening_salary, start1, end1)).to eq((2.30))
    end

    it "reads data and counts overnight salary correctly" do
      file = File.new("spec/fixtures/test.csv")
      simulated_upload = ActionDispatch::Http::UploadedFile.new(tempfile: file)
      results = send(:handle_file, simulated_upload)
      expect(results[1]["Scott Scala"]).to include(39.2)
    end
  end
end
