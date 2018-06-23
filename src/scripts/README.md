To get a better precision on chirp start time, change 'parse_file_metadata.py' in gnuradio source code.

Full path of this file is:  <code_repo_path>/gnuradio/gr-blocks/python/blocks/parse_file_metadata.py

Procedure: 
1. Change the print statement in EXTRACT TIME STAMP section of code.
2. Modify this line to - print "Seconds: {0:.7f}".format(t)
3. Run make and then sudo make install from the build dir.
