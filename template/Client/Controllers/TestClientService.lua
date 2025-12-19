local TestClientService = {}

function TestClientService:foo()
	warn("TestClientService has imported!")

    return self;
end

function TestClientService:bar()
    return "Hi mom from custom-require!";
end

return TestClientService