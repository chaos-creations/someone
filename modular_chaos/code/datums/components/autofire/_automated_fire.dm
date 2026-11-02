// SSautomatedfire keeps scheduled components in buckets of double-linked lists and only clears the bucket head once it processes a bucket.
// The next and prev links of a processed component stay set, so a component that is deleted later is kept alive by the stale links of
// its old neighbours, which hard deletes the gun it belongs to. Human AI hits this whenever a gun is deleted with an AI human mid-burst.

/datum/component/automatedfire/Destroy(force)
	unlink_from_bucket()
	shooter = null
	return ..()

/// Removes the component from the bucket it is scheduled in, if any, so that nothing in SSautomatedfire points to it
/datum/component/automatedfire/proc/unlink_from_bucket()
	if(SSautomatedfire.next_shooter == src)
		SSautomatedfire.next_shooter = next

	var/list/bucket_list = SSautomatedfire.bucket_list
	var/bucket_pos = bucket_list.Find(src)
	if(bucket_pos)
		bucket_list[bucket_pos] = next
		SSautomatedfire.shooter_count--
	else if(prev?.next == src)
		prev.next = next
		SSautomatedfire.shooter_count--

	if(next?.prev == src)
		next.prev = prev

	next = null
	prev = null

// The subsystem reads next before processing, so the links are dropped here once they are stale
/datum/component/automatedfire/autofire/process_shot()
	CAN_BE_REDEFINED(TRUE)
	next = null
	prev = null
	return ..()
