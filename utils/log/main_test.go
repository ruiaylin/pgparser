// Copyright 2017 The Cockroach Authors.
//
// Use of this software is governed by the Business Source License
// included in the file licenses/BSL.txt.
//
// As of the Change Date specified in that file, in accordance with
// the Business Source License, use of this software will be governed
// by the Apache License, Version 2.0, included in the file
// licenses/APL.txt.

package log_test

import (
	"os"
	"testing"

	"github.com/ruiaylin/pgparser/security"
	"github.com/ruiaylin/pgparser/security/securitytest"
	"github.com/ruiaylin/pgparser/pkg/server"
	"github.com/ruiaylin/pgparser/settings/cluster"
	"github.com/ruiaylin/pgparser/pkg/testutils/serverutils"
	"github.com/ruiaylin/pgparser/utils/log"
	"github.com/ruiaylin/pgparser/utils/randutil"
)

func TestMain(m *testing.M) {
	randutil.SeedForTests()
	security.SetAssetLoader(securitytest.EmbeddedAssets)
	serverutils.InitTestServerFactory(server.TestServerFactory)

	// MakeTestingClusterSettings initializes log.ReportingSettings to this
	// instance of setting values.
	// TODO(knz): This comment appears to be untrue.
	st := cluster.MakeTestingClusterSettings()
	log.DiagnosticsReportingEnabled.Override(&st.SV, false)
	log.CrashReports.Override(&st.SV, false)

	os.Exit(m.Run())
}
