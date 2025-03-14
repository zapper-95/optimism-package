def get_enabled_da_server_context(
    plan,
    service_name,
    server_endpoint,
):
    plan.print("Server endpoint: {0}".format(server_endpoint))
    # if using "custom" da-type, the server endpoint is provided
    return new_da_server_context(
        http_url=server_endpoint,
    )


def disabled_da_server_context():
    return new_da_server_context(
        http_url="",
    )


def new_da_server_context(http_url):
    return struct(
        enabled=http_url != "",
        http_url=http_url,
    )
