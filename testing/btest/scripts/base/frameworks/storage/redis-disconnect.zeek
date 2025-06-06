# @TEST-DOC: Tests basic Redis storage backend functions in sync mode, including overwriting

# @TEST-REQUIRES: have-redis
# @TEST-PORT: REDIS_PORT

# @TEST-EXEC: btest-bg-run redis-server run-redis-server ${REDIS_PORT%/tcp}
# @TEST-EXEC: zeek -b %INPUT | sed 's|=[0-9]*/tcp|=xxxx/tcp|g' > out
# @TEST-EXEC: btest-bg-wait -k 0

# @TEST-EXEC: btest-diff out

@load base/frameworks/storage/sync
@load policy/frameworks/storage/backend/redis

redef exit_only_after_terminate = T;

event Storage::backend_opened(tag: Storage::Backend, config: any) {
	print "Storage::backend_opened", tag, config;
}

event Storage::backend_lost(tag: Storage::Backend, config: any, reason: string) {
	print "Storage::backend_lost", tag, config, reason;
	terminate();
}

event zeek_init()
	{
	local opts: Storage::BackendOptions;
	opts$serializer = Storage::STORAGE_SERIALIZER_JSON;
	opts$redis = [ $server_host="127.0.0.1", $server_port=to_port(getenv(
	    "REDIS_PORT")), $key_prefix="testing" ];

	local key = "key1234";
	local value = "value1234";

	local open_res = Storage::Sync::open_backend(Storage::STORAGE_BACKEND_REDIS, opts, string, string);
	print "open_result", open_res;

	# Kill the redis server so the backend will disconnect and fire the backend_lost event.
	system("cat redis-server/redis.pid");
	system("kill $(cat redis-server/redis.pid)");
	}
