using System;

namespace PackageUpdate {
    /// <summary>
    /// 
    /// </summary>
    public class Configuration {
        /// <summary>
        /// Rules for Update Module checking and reporting
        /// </summary>
        public ModuleRule[] CustomRule;
        /// <summary>
        /// Rules for Update Module checking and reporting
        /// </summary>
        public ModuleRule DefaultRule;

        /// <summary>
        /// The minimum interval/timespan has to gone by,for doing a new module update check
        /// </summary>
        public TimeSpan UpdateCheckInterval;

        /// <summary>
        /// Timestamp when last check for update need on modules started
        /// </summary>
        public DateTime LastCheck;

        /// <summary>
        /// Timestamp when last check for update need finished
        /// </summary>
        public DateTime LastSuccessfulCheck;

        /// <summary>
        /// The filepath where to setting file is stored
        /// </summary>
        public string Path;
    }
}
