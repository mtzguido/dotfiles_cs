#!/bin/bash

# Include this from your .bashrc or .bash_aliases with:
#   source ~/.everest-build-this.sh
#
# Then run `everest-build-this` in an F* repo root to start a full
# everest build using your HEAD commit. Uncommitted changes are NOT
# taken, nor are build files (.checked), etc, only whatever is in Git.
# The everest subprojects are taken from hashes.sh file of the current
# everest repo master

# Point this to a local everest checkout to speed up the cloning.
MY_EVEREST=~/r/everest/master

# Parallel factor.
JLEVEL=16 #$(getconf _NPROCESSORS_ONLN)

everest-setup-here () {(
	set -uex

	TEMPDIR=everest-TEMP
	HEAD=$(git rev-parse HEAD)
	git clone github:project-everest/everest --reference "${MY_EVEREST}" "${TEMPDIR}"
	cd "${TEMPDIR}"

	# Get the info on the subprojects.
	source repositories.sh
	source hashes.sh

	# Parallel section begins
	pids=()

		# Clone all subprojects except F* using the local copies as reference:
		# this is fast and does not duplicate objects on disk. We run all of them in
		# parallel, the main delay here is RTT to github.
		for repo in "${!repositories[@]}"; do
			# Skip F*
			if [ "$repo" == "FStar" ]; then continue; fi

			# Clone as usual, but asynchronously.
			( git clone "${repositories[$repo]}" --reference "${MY_EVEREST}"/"$repo" &&
			  git -C "$repo" checkout "${hashes[$repo]}"
			) &
			pids+=($!)
		done

		# Check out (not clone) our local F* repo into the everest sandbox.
		# This does not create a new repo, it only copies the files in the state
		# of the last commit into the FStar/ subdirectory. I would prefer
		# cloning it using '..' as a reference, but git does not support that.
		mkdir FStar
		git --git-dir=../.git --work-tree=FStar restore . &
		pids+=($!)

	# Parallel section ends, wait for everything (explicitly, to catch errors).
	for pid in "${pids[@]}"; do
		wait "$pid"
	done

	# TIP: the fragment above will be the fastest when your local repos
	# are up-to-date and have all necessary objects. If you want to fetch
	# the latest objects without doing an everest pull (e.g. if you have
	# something checkout out that you want to preserve) you can run:
	#   ./everest forall git fetch
	# in your ${MY_EVEREST} directory

	# Get and prepare vale. This has to be done after cloning hacl-star,
	# so we just wait for everything... suboptimal but not too bad.
	./everest get_vale
)}

everest-build-this () {(
	set -uex
	everest-setup-here

	TEMPDIR=everest-TEMP
	cd "${TEMPDIR}"

	# Build. Save total time and a log. Also run with nice so other
	# processes have priority.
	# ramon nice -n 20 bash -c "./everest make -j ${JLEVEL} && ./everest test -j ${JLEVEL}" |& tee BUILD_LOG
	export RESOURCEMONITOR=1
	# job ./everest FStar make -j ${JLEVEL}
	# job ./everest karamel make -j ${JLEVEL}
	# job ./everest hacl-star make -j ${JLEVEL}
	job ./everest make -j ${JLEVEL}
	job ./everest test -j ${JLEVEL}
)}
