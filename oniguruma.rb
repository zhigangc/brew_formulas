require 'formula'

class Oniguruma < Formula
  url 'http://www.geocities.jp/kosako3/oniguruma/archive/onig-5.9.2.tar.gz'
  homepage 'http://www.geocities.jp/kosako3/oniguruma/'
  md5 '0f4ad1b100a5f9a91623e04111707b84'

  def patches
      # let pkg-config see oniguruma
      # we need it for cgo
      DATA
  end
    
  def install
    system "./configure", "--prefix=#{prefix}", "--disable-dependency-tracking"
    system "make install"
  end
end
__END__
diff --git a/Makefile.in b/Makefile.in
index 1c488d7..0894f08 100644
--- a/Makefile.in
+++ b/Makefile.in
@@ -40,6 +40,8 @@ subdir = .
 DIST_COMMON = README $(am__configure_deps) $(include_HEADERS) \
 	$(srcdir)/Makefile.am $(srcdir)/Makefile.in \
 	$(srcdir)/config.h.in $(srcdir)/onig-config.in \
+  $(srcdir)/oniguruma-uninstalled.pc.in \
+  $(srcdir)/oniguruma-2.0.pc.in \
 	$(top_srcdir)/configure AUTHORS COPYING INSTALL config.guess \
 	config.sub depcomp install-sh ltmain.sh missing
 ACLOCAL_M4 = $(top_srcdir)/aclocal.m4
@@ -50,7 +52,7 @@ am__CONFIG_DISTCLEAN_FILES = config.status config.cache config.log \
  configure.lineno config.status.lineno
 mkinstalldirs = $(install_sh) -d
 CONFIG_HEADER = config.h
-CONFIG_CLEAN_FILES = onig-config
+CONFIG_CLEAN_FILES = onig-config oniguruma.pc oniguruma-uninstalled.pc
 am__vpath_adj_setup = srcdirstrip=`echo "$(srcdir)" | sed 's|.|.|g'`;
 am__vpath_adj = case $$p in \
     $(srcdir)/*) f=`echo "$$p" | sed "s|^$$srcdirstrip/||"`;; \
@@ -59,6 +61,9 @@ am__vpath_adj = case $$p in \
 am__strip_dir = `echo $$p | sed -e 's|^.*/||'`;
 am__installdirs = "$(DESTDIR)$(libdir)" "$(DESTDIR)$(bindir)" \
 	"$(DESTDIR)$(includedir)"
+am__base_list = \
+  sed '$$!N;$$!N;$$!N;$$!N;$$!N;$$!N;$$!N;s/\n/ /g' | \
+  sed '$$!N;$$!N;$$!N;$$!N;s/\n/ /g'
 libLTLIBRARIES_INSTALL = $(INSTALL)
 LTLIBRARIES = $(lib_LTLIBRARIES)
 libonig_la_LIBADD =
@@ -276,10 +281,14 @@ EXTRA_DIST = HISTORY README.ja index.html index_ja.html \
 	doc/API doc/API.ja doc/RE doc/RE.ja doc/FAQ doc/FAQ.ja \
 	win32/Makefile win32/config.h win32/testc.c \
 	$(encdir)/koi8.c $(encdir)/mktable.c \
+  oniguruma.pc.in oniguruma-uninstalled.pc.in \
 	$(sampledir)/encode.c $(sampledir)/listcap.c $(sampledir)/names.c \
 	$(sampledir)/posix.c $(sampledir)/simple.c $(sampledir)/sql.c \
 	$(sampledir)/syntax.c
 
+pkgconfigdir = $(libdir)/pkgconfig
+pkgconfig_DATA = oniguruma.pc
+
 bin_SCRIPTS = onig-config
 testc_SOURCES = testc.c
 testc_LDADD = libonig.la
@@ -345,6 +354,10 @@ distclean-hdr:
 	-rm -f config.h stamp-h1
 onig-config: $(top_builddir)/config.status $(srcdir)/onig-config.in
 	cd $(top_builddir) && $(SHELL) ./config.status $@
+oniguruma.pc: $(top_builddir)/config.status $(srcdir)/oniguruma.pc.in
+	cd $(top_builddir) && $(SHELL) ./config.status $@
+oniguruma-uninstalled.pc: $(top_builddir)/config.status $(srcdir)/oniguruma-uninstalled.pc.in
+	cd $(top_builddir) && $(SHELL) ./config.status $@
 install-libLTLIBRARIES: $(lib_LTLIBRARIES)
 	@$(NORMAL_INSTALL)
 	test -z "$(libdir)" || $(MKDIR_P) "$(DESTDIR)$(libdir)"
@@ -410,6 +423,27 @@ uninstall-binSCRIPTS:
 	  rm -f "$(DESTDIR)$(bindir)/$$f"; \
 	done
 
+install-pkgconfigDATA: $(pkgconfig_DATA)
+	@$(NORMAL_INSTALL)
+	test -z "$(pkgconfigdir)" || $(MKDIR_P) "$(DESTDIR)$(pkgconfigdir)"
+	@list='$(pkgconfig_DATA)'; test -n "$(pkgconfigdir)" || list=; \
+	for p in $$list; do \
+	  if test -f "$$p"; then d=; else d="$(srcdir)/"; fi; \
+	  echo "$$d$$p"; \
+	done | $(am__base_list) | \
+	while read files; do \
+	  echo " $(INSTALL_DATA) $$files '$(DESTDIR)$(pkgconfigdir)'"; \
+	  $(INSTALL_DATA) $$files "$(DESTDIR)$(pkgconfigdir)" || exit $$?; \
+	done
+
+uninstall-pkgconfigDATA:
+	@$(NORMAL_UNINSTALL)
+	@list='$(pkgconfig_DATA)'; test -n "$(pkgconfigdir)" || list=; \
+	files=`for p in $$list; do echo $$p; done | sed -e 's|^.*/||'`; \
+	test -n "$$files" || exit 0; \
+	echo " ( cd '$(DESTDIR)$(pkgconfigdir)' && rm -f" $$files ")"; \
+	cd "$(DESTDIR)$(pkgconfigdir)" && rm -f $$files
+
 mostlyclean-compile:
 	-rm -f *.$(OBJEXT)
 
@@ -1136,7 +1170,7 @@ info: info-recursive
 
 info-am:
 
-install-data-am: install-includeHEADERS
+install-data-am: install-includeHEADERS install-pkgconfigDATA
 
 install-dvi: install-dvi-recursive
 
@@ -1175,7 +1209,7 @@ ps: ps-recursive
 ps-am:
 
 uninstall-am: uninstall-binSCRIPTS uninstall-includeHEADERS \
-	uninstall-libLTLIBRARIES
+	uninstall-libLTLIBRARIES uninstall-pkgconfigDATA
 
 .MAKE: $(RECURSIVE_CLEAN_TARGETS) $(RECURSIVE_TARGETS) install-am \
 	install-strip
diff --git a/configure b/configure
index 43657a7..e049f4d 100755
--- a/configure
+++ b/configure
@@ -13220,7 +13220,7 @@ _ACEOF
 fi
 
 
-ac_config_files="$ac_config_files Makefile onig-config sample/Makefile"
+ac_config_files="$ac_config_files Makefile onig-config sample/Makefile oniguruma.pc oniguruma-uninstalled.pc"
 
 ac_config_commands="$ac_config_commands default"
 
@@ -14060,6 +14060,8 @@ do
     "Makefile") CONFIG_FILES="$CONFIG_FILES Makefile" ;;
     "onig-config") CONFIG_FILES="$CONFIG_FILES onig-config" ;;
     "sample/Makefile") CONFIG_FILES="$CONFIG_FILES sample/Makefile" ;;
+    "oniguruma.pc") CONFIG_FILES="$CONFIG_FILES oniguruma.pc" ;;
+    "oniguruma-uninstalled.pc") CONFIG_FILES="$CONFIG_FILES oniguruma-uninstalled.pc" ;;
     "default") CONFIG_COMMANDS="$CONFIG_COMMANDS default" ;;
 
   *) { { echo "$as_me:$LINENO: error: invalid argument: $ac_config_target" >&5
diff --git a/oniguruma-uninstalled.pc.in b/oniguruma-uninstalled.pc.in
new file mode 100644
index 0000000..99a923f
--- /dev/null
+++ b/oniguruma-uninstalled.pc.in
@@ -0,0 +1,12 @@
+prefix=
+exec_prefix=
+libdir=${pcfiledir}
+includedir=${pcfiledir}/include
+
+
+Name: oniguruma
+Version: @VERSION@
+Description: oniguruma regular expression library
+Requires:
+Libs: -L${libdir} -lonig
+Cflags: -I${includedir}
diff --git a/oniguruma.pc.in b/oniguruma.pc.in
new file mode 100644
index 0000000..8feccc2
--- /dev/null
+++ b/oniguruma.pc.in
@@ -0,0 +1,12 @@
+prefix=@prefix@
+exec_prefix=@exec_prefix@
+libdir=@libdir@
+includedir=@includedir@
+modules=@WITH_MODULES@
+
+Name: oniguruma
+Version: @VERSION@
+Description: oniguruma regular expression library
+Requires:
+Libs: -L${libdir} -lonig
+Cflags: -I${includedir}
