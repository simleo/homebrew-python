require 'formula'

# Todo: Install examples, run test
# todo: What about sdl_gfx?
# todo: depends_on :x11 ???

class Pygame < Formula
  homepage 'http://pygame.org'
  url 'http://pygame.org/ftp/pygame-1.9.1release.tar.gz'
  sha1 'a45aeb0623e36ae7a1707b5f41ee6274f72ca4fa'
  head 'https://bitbucket.org/pygame/pygame', :using => :hg

  depends_on 'sdl'
  depends_on 'sdl_image'
  depends_on 'sdl_mixer'
  depends_on 'sdl_ttf'
  depends_on 'smpeg'
  depends_on 'jpeg'
  depends_on 'libpng'
  depends_on 'portmidi'
  depends_on 'numpy'

  def patches
    # Upstream https://bitbucket.org/pygame/pygame/issue/94/src-scale_mmx64c-cannot-be-compiled-with
    # Will be fixed in next release.
    if not build.head?
      { :p0 => 'https://bitbucket.org/pygame/pygame/issue-attachment/94/pygame/pygame/20111022/94/patch-src_scale_mmx64.c.diff' }
    end
  end

  def install
    # In order to install into the Cellar, the dir must exist and be in the
    # PYTHONPATH.
    temp_site_packages = lib/which_python/'site-packages'
    mkdir_p temp_site_packages
    ENV['PYTHONPATH'] = temp_site_packages

    # We provide a "Setup" file based on the "Setup.in" because the detection
    # code in config.py does not know about the HOMEBREW_PREFIX, assumes SDL
    # is built as a framework and cannot find the Frameworks inside of Xcode.
    mv 'Setup.in', 'Setup'
    sdl = Formula.factory('sdl').opt_prefix
    sdl_ttf = Formula.factory('sdl_ttf').opt_prefix
    sdl_image = Formula.factory('sdl_image').opt_prefix
    sdl_mixer = Formula.factory('sdl_mixer').opt_prefix
    smpeg = Formula.factory('smpeg').opt_prefix
    png = Formula.factory('libpng').opt_prefix
    jpeg = Formula.factory('jpeg').opt_prefix
    portmidi = Formula.factory('portmidi').opt_prefix
    inreplace 'Setup' do |s|
      s.gsub!(/^SDL =.*$/, "SDL = -I#{sdl}/include/SDL -Ddarwin -lSDL")
      s.gsub!(/^FONT =.*$/, "FONT = -I#{sdl_ttf}/include/SDL -lSDL_ttf")
      s.gsub!(/^IMAGE =.*$/, "IMAGE = -I#{sdl_image}/include/SDL -lSDL_image")
      s.gsub!(/^MIXER =.*$/, "MIXER = -I#{sdl_mixer}/include/SDL -lSDL_mixer")
      s.gsub!(/^SMPEG =.*$/, "SMPEG = -I#{smpeg}/include/smpeg -lsmpeg")
      s.gsub!(/^PNG =.*$/, "PNG = -lpng")
      s.gsub!(/^JPEG =.*$/, "JPEG = -ljpeg")
      s.gsub!(/^PORTMIDI =.*$/, "PORTMIDI = -I#{portmidi}/include/ -lportmidi")
      s.gsub!(/^PORTTIME =.*$/, "PORTTIME = -I#{portmidi}/include/ -lportmidi")
    end

    # Manually append what is the default for PyGame on the Mac
    system "cat Setup_darwin.in >> Setup"

    args = [
      "--no-user-cfg",
      "--verbose",
      "install",
      "--force",
      "--install-scripts=#{share}/python",
      "--install-lib=#{temp_site_packages}",
      "--install-data=#{share}",
      "--install-headers=#{include}",
    ]
    system "python", "-s", "setup.py", *args
  end

  def test
    raise 'no test yet'
  end

  def which_python
    "python" + `python -c 'import sys;print(sys.version[:3])'`.strip
  end
end
