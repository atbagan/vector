package metadata

components: sinks: loki: {
	title:       "Loki"
	description: "[Loki][urls.loki] is a horizontally-scalable, highly-available, multi-tenant log aggregation system inspired by [Prometheus][urls.prometheus]. It is designed to be very cost effective and easy to operate. It does not index the contents of the logs, but rather a set of labels for each log stream."

	classes: {
		commonly_used: true
		delivery:      "at_least_once"
		development:   "beta"
		egress_method: "batch"
		service_providers: ["Grafana"]
	}

	features: {
		buffer: enabled:      true
		healthcheck: enabled: true
		send: {
			batch: {
				enabled:      true
				common:       false
				max_events:   100000
				max_bytes:    null
				timeout_secs: 1
			}
			compression: enabled: false
			encoding: {
				enabled: true
				codec: {
					enabled: true
					default: "json"
					enum: ["json", "text"]
				}
			}
			request: {
				enabled:                    true
				concurrency:                5
				rate_limit_duration_secs:   1
				rate_limit_num:             5
				retry_initial_backoff_secs: 1
				retry_max_duration_secs:    10
				timeout_secs:               60
			}
			tls: {
				enabled:                true
				can_enable:             false
				can_verify_certificate: true
				can_verify_hostname:    true
				enabled_default:        false
			}
			to: {
				service: {
					name:     "Loki"
					thing:    "a \(name) database"
					url:      urls.loki
					versions: null
				}

				interface: {
					socket: {
						direction: "outgoing"
						protocols: ["http"]
						ssl: "optional"
					}
				}
			}
		}
	}

	support: {
		targets: {
			"aarch64-unknown-linux-gnu":  true
			"aarch64-unknown-linux-musl": true
			"x86_64-apple-darwin":        true
			"x86_64-pc-windows-msv":      true
			"x86_64-unknown-linux-gnu":   true
			"x86_64-unknown-linux-musl":  true
		}

		requirements: []
		warnings: []
		notices: []
	}

	configuration: {
		auth: configuration._http_auth & {_args: {
			password_example: "${LOKI_PASSWORD}"
			username_example: "${LOKI_USERNAME}"
		}}
		labels: {
			description: "A set of labels that will be attached to each batch of events. These values are also templateable to allow events to provide dynamic label values.Note: If the set of label values has high cardinality this can cause drastic performance issues with Loki. To ensure this does not happen one should try to reduce the amount of unique label values."
			required:    true
			warnings: []
			type: object: {
				examples: [
					{
						"forwarder": "vector"
						"event":     "{{ event_field }}"
						"key":       "value"
					},
				]
				options: {
					"*": {
						common:      false
						description: "Any Loki label"
						required:    false
						type: string: {
							default: null
							examples: ["vector", "{{ event_field }}"]
							templateable: true
						}
					}
				}
			}
		}
		remove_label_fields: {
			common:      false
			description: "If this is set to `true` then when labels are collected from events those fields will also get removed from the event."
			required:    false
			warnings: []
			type: bool: default: false
		}
		remove_timestamp: {
			common:      false
			description: "If this is set to `true` then the timestamp will be removed from the event. This is useful because Loki uses the timestamp to index the event."
			required:    false
			warnings: []
			type: bool: default: true
		}
		tenant_id: {
			common:      false
			description: "The tenant id that will be sent with every request, by default this is not required since a proxy should set this header. When running Loki locally a tenant id is not required either.\n\nYou can read more about tenant id's [here][urls.loki_multi_tenancy]"
			required:    false
			warnings: []
			type: string: {
				default: null
				examples: ["some_tenant_id"]
			}
		}
	}

	input: {
		logs:    true
		metrics: null
	}

	how_it_works: {
		decentralized_deployments: {
			title: "Decentralized Deployments"
			body: """
				Loki currently does not support out-of-order inserts. If
				Vector is deployed in a decentralized setup then there is
				the possibility that logs might get rejected due to data
				races between Vector instances. To avoid this we suggest
				either assigning each Vector instance with a unique label
				or deploying a centralized Vector which will ensure no logs
				will get sent out-of-order.
				"""
		}

		event_ordering: {
			title: "Event Ordering"
			body: """
				The `loki` sink will ensure that all logs are sorted via
				their `timestamp`. This is to ensure that logs will be
				accepted by Loki. If no timestamp is supplied with events
				then the Loki sink will supply its own monotonically
				increasing timestamp.
				"""
		}
	}
}
