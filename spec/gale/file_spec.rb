require File.expand_path "../../teststrap", __FILE__

describe Gale::File do
  context "class" do
    describe "new" do
      it "fails if the file doesn't exist" do
        ->{ described_class.new "blob.gal" }.should raise_error(Errno::ENOENT, /File not found/)
      end

      it "fails if the file has a bad format" do
        ->{ described_class.new __FILE__ }.should raise_error(Gale::FormatError, /File not in GraphicsGale format/)
      end
    end
  end

  context "loaded an animation" do
    subject do
      described_class.new File.expand_path("../data/cop_ranged.gal", File.dirname(__FILE__))
    end

    after do
      subject.close
    end

    describe "num_frames" do
      it "counts the number of frames" do
        subject.num_frames.should eq 5
      end
    end

    describe "width" do
      it "gets the width" do
        subject.width.should eq 28
      end
    end

    describe "height" do
      it "gets the height" do
        subject.height.should eq 24
      end
    end

    describe "background_color" do
      it "gets the color" do
        subject.background_color.should eq Gosu::Color::WHITE
      end
    end

    describe "bits_per_pixel" do
      it "gets the bbp" do
        subject.bits_per_pixel.should eq 24
      end
    end

    context "frames" do
      describe "num_layers" do
        it "counts the layers in every available frame" do
          subject.num_frames.times.map {|f| subject.num_layers f }.should eq [1, 1, 2, 1, 1]
        end
      end

      describe "frame_delay" do
        it "gets delays from each frame" do
          subject.num_frames.times.map {|f| subject.frame_delay(f) }.should eq [500, 375, 125, 250, 250]
        end
      end

      describe "transparent_color" do
        it "gets transparent_color from each frame" do
          subject.num_frames.times do |f|
            subject.frame_transparent_color(f).should eq Gosu::Color.rgb(253, 77, 211)
          end
        end
      end

      describe "frame_name" do
        it "gets frame names" do
          subject.num_frames.times.map {|f| subject.frame_name(f) }.should eq %w[stand aim bang recoil recover]
        end
      end

      context "layers" do
        describe "layer_name" do
          it "gets layer names" do
            subject.num_frames.times.map do |f|
              subject.num_layers(f).times.map do |l|
                subject.layer_name(f, l)
              end
            end.should eq [%w[Layer1], %w[Layer1], %w[cop flare], %w[Layer1], %w[Layer1]]
          end
        end
      end
    end
  end

=begin
  gg_image.num_frames.times {|f| subject.export_as_bitmap("frame_#{f}.bmp", f) }

  gg_image.to_blob(0, 0)
  $window = Gosu::Window.new(10, 10, false)
  gosu_image = Gosu::Image.from_blob $window, gg_image.to_blob(0, 0), gg_image.width, gg_image.height
=end
end
