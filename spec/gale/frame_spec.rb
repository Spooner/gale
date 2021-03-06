require File.expand_path "../../teststrap", __FILE__

describe Gale::Frame do
  before :all do
    $window = Gosu::Window.new(10, 10, false)
  end

  subject do
    Gale::File.new COP_RANGED_GAL
  end

  after do
    subject.close
  end


  describe "#size" do
    it "counts the layers in the frame" do
      subject.map(&:size).should eq [1, 2, 2, 1, 1]
    end
  end

  describe "#index" do
    it "is the ordered index of the frame within the file" do
      subject.map(&:index).should eq [0, 1, 2, 3, 4]
    end
  end

  describe "#delay" do
    it "gets delay, in ms" do
      subject.map(&:delay).should eq [500, 375, 125, 250, 250]
    end
  end

  describe "#transparent_color" do
    it "gets transparent color" do
      c = 0xfd4dd3
      subject.map(&:transparent_color).should eq [c, c, c, c, nil]
    end
  end

  describe "#transparent_color?" do
    it "is true if transparent color is set" do
      subject.map(&:transparent_color?).should eq [true, true, true, true, false]
    end
  end

  describe "#name" do
    it "gets name" do
      subject.map(&:name).should eq %w[stand aim bang recoil recover]
    end
  end

  describe "#disposal" do
    it "gets disposal method" do
      subject.map(&:disposal).should eq [:background, :previous, :background, :no_disposal, :none]
    end
  end

  describe "#export_bitmap" do
    it "should export the composed frame as a bitmap" do
      subject.each do |frame|
        file = "test_output/frame_#{frame.index}.bmp"
        frame.export_bitmap file
        File.exists?(file).should be_true
        File.size(file).should be > 0
      end
    end
  end
end
